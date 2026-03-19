# == Schema Information
#
# Table name: cart_products
#
#  id             :bigint           not null, primary key
#  quantity       :integer          default(1), not null
#  value_currency :string           default("brl"), not null
#  value_subcents :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_id      :bigint           not null
#  product_id     :bigint           not null
#
# Indexes
#
#  index_cart_products_on_client_id   (client_id)
#  index_cart_products_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (product_id => products.id)
#
class CartProduct < ApplicationRecord
  belongs_to :product
  belongs_to :client, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :validate_product_quantity

  monetize :value_subcents, as: :value, with_currency: :brl

  def set_default_fields(company_config)
    self.value = company_config.calculate_product_value(self.product.value)
  end

  def available_quantity
    self.product.available_quantity
  end

  private

  def validate_product_quantity
    if self.quantity > self.product.available_quantity
      self.errors.add(:quantity, "insuficiente em estoque")
    end
  end
end
