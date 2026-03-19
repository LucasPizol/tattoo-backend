# == Schema Information
#
# Table name: stocks
#
#  id         :bigint           not null, primary key
#  quantity   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_stocks_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Stock < ApplicationRecord
  has_many :stock_movements, dependent: :destroy
  has_many :order_products, dependent: :destroy

  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
