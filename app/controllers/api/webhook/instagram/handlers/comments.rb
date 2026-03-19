class Api::Webhook::Instagram::Handlers::Comments
  include ClassLogger

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def create_comment
    ActiveRecord::Base.transaction do
      Instagram::Comment.create!(body_object)
    end

    true
  rescue StandardError => e
    log_error("Error creating instagram comment: #{e.message}")
    false
  end

  private

  def instagram_post
    @instagram_post ||= Instagram::Post.find_by!(ig_media_id: instagram_post_id)
  end

  def instagram_account
    @instagram_account ||= Instagram::Account.find_by(ig_id: instagram_account_id) ||
      Instagram::Account.create!(
        ig_id: instagram_account_id,
        ig_username: username,
        company: instagram_post.company
      )
  end

  def body_object
    data = {
      text: value[:text],
      username: username,
      ig_comment_id: value[:id],
      post: instagram_post,
      account: instagram_account
    }

    data[:parent_comment] = Instagram::Comment.find_by(ig_comment_id: value[:parent_id]) if value[:parent_id].present?

    data
  end

  def username
    value[:from][:username]
  end

  def instagram_post_id
    value[:media][:id]
  end

  def instagram_account_id
    value[:from][:id]
  end
end
