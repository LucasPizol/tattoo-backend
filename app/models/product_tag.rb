# == Schema Information
#
# Table name: product_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#  tag_id     :integer          not null
#
# Indexes
#
#  index_product_tags_on_product_id             (product_id)
#  index_product_tags_on_product_id_and_tag_id  (product_id,tag_id) UNIQUE
#  index_product_tags_on_tag_id                 (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (tag_id => tags.id)
#
class ProductTag < ApplicationRecord
  belongs_to :product
  belongs_to :tag

  def self.ransackable_attributes(auth_object = nil)
    %w[product_id tag_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product tag]
  end
end
