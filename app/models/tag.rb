# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  notes      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#  tag_id     :integer
#  user_id    :bigint
#
# Indexes
#
#  index_tags_on_company_id  (company_id)
#  index_tags_on_tag_id      (tag_id)
#  index_tags_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (tag_id => tags.id)
#  fk_rails_...  (user_id => users.id)
#
class Tag < ApplicationRecord
  belongs_to :parent_tag, class_name: "Tag", optional: true, foreign_key: :tag_id
  belongs_to :company
  has_many :tags, foreign_key: :tag_id, dependent: :destroy
  has_many :product_tags, dependent: :destroy
  has_many :products, through: :product_tags

  validates :name, presence: true
  validates :company, presence: true

  after_save { Rails.cache.delete("tag_tree_#{company_id}") }
  after_destroy { Rails.cache.delete("tag_tree_#{company_id}") }

  scope :with_products, -> {
    product_ids = Product.featured.with_images.select(:id)
    tag_ids_with_products = joins(:product_tags)
                                 .where(product_tags: { product_id: product_ids })
                                 .distinct
                                 .pluck(:id, :tag_id)

    all_tags = Tag.pluck(:id, :tag_id).to_h

    ancestor_ids = Set.new
    tag_ids_with_products.each do |id, parent_id|
      current_parent = parent_id
      while current_parent.present?
        ancestor_ids << current_parent
        current_parent = all_tags[current_parent]
      end
    end

    ids_with_products = tag_ids_with_products.map(&:first)
    where(id: ids_with_products + ancestor_ids.to_a)
  }

  def self.build_tree(company_id)
    Rails.cache.fetch("tag_tree_#{company_id}", expires_in: 1.hour) do
      tags = Tag.where(company_id: company_id).group_by(&:tag_id)

      build_children = ->(parent) do
        (tags[parent&.id] || []).map do |tag|
          {
            id: tag.id,
            name: tag.name,
            notes: tag.notes,
            children: build_children.call(tag),
            parentTag: parent ? {
              id: tag.tag_id,
              name: tag.parent_tag.name
            } : nil
          }
        end
      end

      build_children.call(nil)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end
end
