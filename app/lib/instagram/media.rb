# frozen_string_literal: true

module Instagram::Media
  def create_container(post)
    account = post.account
    media_container_ids = create_media_containers(post, account)

    if media_container_ids.size > 1
      response = http_client(token: account.ig_access_token).post(
        "#{graph_url}/#{account.ig_id}/media",
        {
          media_type: "CAROUSEL",
          caption: post.caption,
          children: media_container_ids.join(",")
        }.to_json
      )

      unless response.success?
        raise "Failed to create carousel: #{response.body}"
      end

      {
        carousel_id: response.body["id"].to_s,
        media_container_ids: media_container_ids
      }
    else
      {
        media_container_ids: media_container_ids,
        carousel_id: nil
      }
    end
  end

  def check_media_status(container_id:, account:)
    response = http_client(token: account.ig_access_token).get(
      "#{graph_url}/#{container_id}?fields=status_code"
    )

    unless response.success?
      raise "Failed to check media status: #{response.body}"
    end

    response.body["status_code"]
  end

  def publish(media_container_id:, account:)
    response = http_client(token: account.ig_access_token).post(
      "#{graph_url}/#{account.ig_id}/media_publish",
      { creation_id: media_container_id }.to_json
    )

    if response.success?
      response.body["id"]
    else
      raise "Failed to publish media: #{response.body}"
    end
  end

  def list_media(account:, after: nil)
    url = "#{graph_url}/#{account.ig_id}/media?fields=id,caption,media_url,media_type,comments_count,like_count,media_product_type,thumbnail_url,username,view_count,timestamp,permalink"
    url += "&after=#{CGI.escape(after)}" if after.present?

    response = http_client(token: account.ig_access_token).get(url)

    if response.success?
      response.body
    else
      raise "Failed to list media: #{response.body}"
    end
  end

  def list_all_media(account:, &block)
    all_media = []
    after = nil

    loop do
      result = list_media(account: account, after: after)
      data = result["data"] || []
      all_media.concat(data)

      cursors = result.dig("paging", "cursors")
      after = cursors&.dig("after")
      break if after.blank?

      block.call(result) if block_given?
    end

    all_media
  end

  def get_media(media_id, account:)
    response = http_client(token: account.ig_access_token).get(
      "#{graph_url}/#{media_id}?fields=id,caption,media_url,media_type,comments_count,like_count,media_product_type,thumbnail_url,username,view_count,timestamp&access_token=#{account.ig_access_token}"
    )

    if response.success?
      response.body
    else
      raise "Failed to get media: #{response.body}"
    end
  end

  private

  def create_media_containers(post, account)
    post.contents.map do |content|
      response = http_client(token: account.ig_access_token).post(
        "#{graph_url}/#{account.ig_id}/media",
        post.build_content(content).to_json
      )

      unless response.success?
        raise "Failed to create media container: #{response.body}"
      end

      response.body["id"].to_s
    end
  end
end
