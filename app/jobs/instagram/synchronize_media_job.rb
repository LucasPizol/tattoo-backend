class Instagram::SynchronizeMediaJob < ApplicationJob
  def perform(account_id)
    account = Instagram::Account.find(account_id)
    client = Instagram::Client.new
    all_media = client.list_all_media(account: account) do |result|
      result["data"].each do |media|
        post = Instagram::Post.find_or_initialize_by(ig_media_id: media["id"], account: account)

        post.caption =                media["caption"]
        post.ig_media_url =           media["media_url"]
        post.ig_media_type =          media["media_type"]
        post.ig_comments_count =      media["comments_count"]
        post.ig_like_count =          media["like_count"]
        post.ig_media_product_type =  media["media_product_type"]
        post.ig_thumbnail_url =       media["thumbnail_url"]
        post.ig_username =            media["username"]
        post.ig_view_count =          media["view_count"]
        post.status =                 "published"
        post.published_at =           Time.zone.parse(media["timestamp"])
        post.ig_permalink =           media["permalink"]

        post.save!

        sync_comments(client: client, post: post, media_id: media["id"], account: account)
      end
    end
  end

  private

  def sync_comments(client:, post:, media_id:, account:)
    comments = client.list_all_comments(media_id: media_id, account: account) do |result|
      data = result["data"] || []
      data.each do |api_comment|
        sync_comment(api_comment: api_comment, post: post, account: account, parent: nil)
      end
    end
  end

  def sync_comment(api_comment:, post:, account:, parent:)
    record = Instagram::Comment.find_or_initialize_by(
      ig_comment_id: api_comment["id"],
      post: post,
      account: account
    )

    record.assign_attributes(
      text: api_comment["text"].to_s,
      username: api_comment["username"].presence || "unknown",
      parent_comment: parent
    )

    timestamp = api_comment["timestamp"] || api_comment["created_at"]
    record.created_at = Time.zone.parse(timestamp) if record.new_record? && timestamp.present?

    record.save!
  end
end
