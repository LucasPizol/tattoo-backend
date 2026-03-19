class Instagram::PublishContentJob < ApplicationJob
  sidekiq_options queue: :default

  STATUS_MAPPER = {
    "ERROR" => "failed",
    "IN_PROGRESS" => "publishing",
    "EXPIRED" => "failed",
    "PUBLISHED" => "published",
    "FINISHED" => "publishing"
  }

  MAX_RETRIES = 10
  RETRY_DELAY = 5

  attr_reader :instagram_post

  def perform(instagram_post_id)
    @instagram_post = Instagram::Post.find(instagram_post_id)
    client = Instagram::Client.new

    if instagram_post.ig_container_id.blank? && instagram_post.ig_carousel_id.blank?
      media_container = client.create_container(instagram_post)
      instagram_post.update!(ig_container_id: media_container[:media_container_ids].join(","), ig_carousel_id: media_container[:carousel_id])

      sleep(15)
    end

    retries = 0
    container_id = instagram_post.ig_carousel_id.presence || instagram_post.ig_container_id

    while true do
      status = client.check_media_status(container_id: container_id, account: instagram_post.account)
      break unless %w[IN_PROGRESS].include?(status)
      sleep(RETRY_DELAY)
      retries += 1
      break if retries >= MAX_RETRIES
    end

    new_status = STATUS_MAPPER[status]
    instagram_post.update!(status: new_status) if new_status.present?

    return if instagram_post.published?

    media_container_id = instagram_post.ig_carousel_id || instagram_post.ig_container_id

    media_id = client.publish(media_container_id: media_container_id, account: instagram_post.account)
    instagram_post.update!(status: "published",  ig_media_id: media_id, published_at: Time.current, error_message: nil)

    CompanyChannel.broadcast_to(instagram_post.company, {
      type: "instagram_post_published",
      instagramPost: {
        id: instagram_post.id,
        status: instagram_post.status,
        publishedAt: instagram_post.published_at&.in_time_zone("Brasilia")&.iso8601
      }
    })
    log_info("Instagram content published: #{instagram_post.id}")
  rescue StandardError => e
    log_error("Error publishing instagram content: #{e.message}")
    instagram_post.update(status: "failed", error_message: e.message)

    CompanyChannel.broadcast_to(instagram_post.company, {
      type: "instagram_post_failed",
      instagramPost: {
        id: instagram_post.id,
        status: instagram_post.status
      }
    })
    raise e
  end
end
