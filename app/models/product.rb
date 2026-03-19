# == Schema Information
#
# Table name: products
#
#  id                  :bigint           not null, primary key
#  carousel            :boolean          default(FALSE), not null
#  cost_value_currency :string           default("br")
#  cost_value_subcents :integer          default(0)
#  description         :text
#  featured            :boolean          default(FALSE), not null
#  name                :string           not null
#  new                 :boolean          default(FALSE), not null
#  product_type        :string
#  require_responsible :boolean          default(FALSE), not null
#  sku                 :string           not null
#  slug                :string           not null
#  value_currency      :string           default("brl"), not null
#  value_subcents      :bigint           default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer          not null
#  material_id         :integer
#  user_id             :bigint
#
# Indexes
#
#  index_products_on_company_id           (company_id)
#  index_products_on_company_id_and_sku   (company_id,sku) UNIQUE
#  index_products_on_cost_value_currency  (cost_value_currency)
#  index_products_on_cost_value_subcents  (cost_value_subcents)
#  index_products_on_material_id          (material_id)
#  index_products_on_material_id_and_sku  (material_id,sku) UNIQUE
#  index_products_on_name_trgm            (name) USING gin
#  index_products_on_sku                  (sku) UNIQUE
#  index_products_on_slug                 (slug) UNIQUE
#  index_products_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (material_id => materials.id)
#  fk_rails_...  (user_id => users.id)
#
class Product < ApplicationRecord
  include ProcessesAttachmentsVariants

  PERCENTAGE_ON_STOCK = 0.5

  has_many_attached :images do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 200, 200 ]
    attachable.variant :catalog, resize_to_limit: [ 500, 500 ]
  end

  belongs_to :material
  belongs_to :company
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :material, presence: true
  validates :slug, presence: true

  monetize :value_subcents, as: :value, with_currency: :brl
  monetize :cost_value_subcents, as: :cost_value, with_currency: :brl

  normalizes :name, with: ->(name) { name.strip.titleize }

  before_create :set_default_field
  after_save :build_sku, if: -> { saved_change_to_material_id? }

  has_many :stocks, dependent: :destroy
  has_many :order_products, dependent: :destroy, through: :stocks
  has_many :orders, through: :order_products
  has_many :product_tags, dependent: :destroy
  has_many :tags, through: :product_tags

  scope :featured, -> { where(featured: true).available }
  scope :latest, -> { order(created_at: :desc) }
  scope :available, -> { joins(:stocks).group("products.id").having("SUM(stocks.quantity * #{PERCENTAGE_ON_STOCK}) >= 1") }
  scope :with_images, -> { joins(:images_attachments) }
  scope :best_seller, -> { joins(:order_products).group("products.id").order("SUM(order_products.quantity) DESC") }
  scope :carousel, -> { where(carousel: true) }
  scope :as_new, -> { where(new: true) }
  scope :without_stock, -> { joins(:stocks).group("products.id").having("SUM(stocks.quantity) = 0") }
  scope :with_stock, -> { joins(:stocks).group("products.id").having("SUM(stocks.quantity) > 0") }

  scope :search_by_name, ->(query) {
    return none if query.blank?

    where(
      "name % :q OR unaccent(name) ILIKE unaccent(:like)",
      q: query,
      like: "%#{query}%"
    ).order(
      Arel.sql(
        "similarity(name, #{ActiveRecord::Base.connection.quote(query)}) DESC"
      )
    )
  }

  before_validation :set_slug, if: -> { will_save_change_to_name? }

  def catalog_url
    "#{Rails.application.config.action_mailer.default_url_options[:host]}/thumbnails/#{self.images.first.id}/500x500.jpg"
  end

  def catalog_url_base64
    if self.images.first.present?
      image_data = self.images.first.download
      "data:image/jpeg;base64,#{Base64.strict_encode64(image_data)}"
    end
  end

  def build_image_data
    self.images.map do |image|
      image_data = {
        id: image.id,
        filename: image.filename,
        contentType: image.content_type,
        byteSize: image.byte_size,
        url: "https://rainbow-piercing-bucket-v2.s3.amazonaws.com/#{image.key}"
      }

      variant = image.image? ? image.variant(:thumbnail) : nil
      processed = variant&.processed
      image_data[:thumbnailUrl] = "https://rainbow-piercing-bucket-v2.s3.amazonaws.com/#{processed.key}" if processed

      image_data
    end
  end

  def thumbnail_url(image)
    return nil if image.blank?

    variant = image.image? ? image.variant(:thumbnail) : nil
    processed = variant&.processed

    "https://rainbow-piercing-bucket-v2.s3.amazonaws.com/#{processed.key}" if processed
  end

  def available_quantity
    (self.stocks.sum(&:quantity) * Product::PERCENTAGE_ON_STOCK).to_i
  end

  private

  def set_slug
    if Product.exists?(slug: self.name.parameterize)
      self.slug = "#{self.name.parameterize}-#{self.id}"
    else
      self.slug = self.name.parameterize
    end
  end

  def set_default_field
    return if self.material.blank?

    self.sku = "#{self.material.name.parameterize.upcase}-#{self.name}"
  end

  def build_sku
    return if self.material.blank?

    self.sku = "#{self.material.name.parameterize.upcase}-#{self.id}"
    self.save!
  end

  def remove_thumbnails
    self.images.each do |image|
      FileUtils.rm_rf(Rails.root.join("public", "thumbnails", image.id.to_s))
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    super
  end

  def self.ransackable_associations(auth_object = nil)
    super + %w[material product_tags tags]
  end
end
