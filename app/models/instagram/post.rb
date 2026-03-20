# == Schema Information
#
# Table name: instagram_posts
#
#  id                    :bigint           not null, primary key
#  caption               :string           not null
#  error_message         :text
#  ig_comments_count     :integer
#  ig_like_count         :integer
#  ig_media_product_type :string
#  ig_media_type         :string
#  ig_media_url          :string
#  ig_permalink          :string
#  ig_thumbnail_url      :string
#  ig_username           :string
#  ig_view_count         :integer
#  published_at          :datetime
#  status                :string           default("draft"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  ig_carousel_id        :string
#  ig_container_id       :string
#  ig_media_id           :string
#  instagram_account_id  :integer          not null
#
# Indexes
#
#  index_instagram_posts_on_ig_media_id            (ig_media_id) UNIQUE
#  index_instagram_posts_on_ig_media_product_type  (ig_media_product_type)
#  index_instagram_posts_on_ig_media_type          (ig_media_type)
#  index_instagram_posts_on_ig_username            (ig_username)
#  index_instagram_posts_on_instagram_account_id   (instagram_account_id)
#  index_instagram_posts_on_status                 (status)
#
# Foreign Keys
#
#  fk_rails_...  (instagram_account_id => instagram_accounts.id)
#
class Instagram::Post < ApplicationRecord
  self.table_name = "instagram_posts"

  has_many :comments, class_name: "Instagram::Comment", foreign_key: :instagram_post_id, primary_key: :id, dependent: :destroy
  has_many :raffles, dependent: :destroy, inverse_of: :instagram_post
  belongs_to :account, class_name: "Instagram::Account", foreign_key: :instagram_account_id, primary_key: :id
  has_one :company, through: :account
  has_many_attached :contents, dependent: :destroy

  MEDIA_TYPES = %w[IMAGE VIDEO REELS STORIES]
  STATUSES = %w[draft publishing published failed]

  validates :caption, presence: true
  validates :status, inclusion: { in: STATUSES }

  enum :status, STATUSES.index_by(&:itself)

  VALID_CONTENT_TYPES = {
    "IMAGE" => %w[image/jpeg image/png image/gif],
    "VIDEO" => %w[video/mp4 video/mov video/avi video/mkv],
    "REELS" => %w[video/mp4 video/mov video/avi video/mkv],
    "STORIES" => %w[video/mp4 video/mov video/avi video/mkv image/jpeg image/png image/gif]
  }

  MAX_CONTENT_PER_MEDIA_TYPE = {
    "IMAGE" => 10,
    "VIDEO" => 10,
    "REELS" => 1,
    "STORIES" => 1
  }

  def publish
    self.status = "publishing"
    self.save!

    Instagram::PublishContentJob.perform_async(self.id)
  end

  def short_caption
    caption.slice(0, 35) + (caption.length > 35 ? "..." : "")
  end

  def build_content_url(content)
    "#{base_url}/#{content.key}"
  end

  def build_content_media_type(content)
    if content.image?
      "IMAGE"
    else
      "REELS"
    end
  end

  def build_content(content)
    body = {
      media_type: build_content_media_type(content),
      caption: caption
    }

    # body[:image_url] = build_url(content) if content.image?
    # body[:video_url] = build_url(content) if content.video?

    body[:image_url] = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfnzemlLlPLlkJMjzYn-JwNI3fXZ-6QH04Wg&s"

    if contents.size > 1 && content.video?
      body[:is_carousel_item] = true
      body[:media_type] = "VIDEO"
    end

    body
  end

  def build_url(content)
    "#{base_url}/#{content.key}"
  end

  private

  def base_url
    "https://tattoo-bucket-v1.s3.amazonaws.com"
  end
end
