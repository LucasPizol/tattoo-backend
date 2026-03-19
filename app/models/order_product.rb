# == Schema Information
#
# Table name: order_products
#
#  id                  :bigint           not null, primary key
#  cost_value_currency :string           default("BRL"), not null
#  cost_value_subcents :integer          default(0), not null
#  quantity            :integer          default(1), not null
#  value_currency      :string           default("br"), not null
#  value_subcents      :integer          default(0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_id            :integer          not null
#  stock_id            :bigint
#
# Indexes
#
#  index_order_products_on_order_id               (order_id)
#  index_order_products_on_order_id_and_stock_id  (order_id,stock_id) UNIQUE
#  index_order_products_on_stock_id               (stock_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (stock_id => stocks.id)
#
class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :stock

  has_one :product, through: :stock

  monetize :value_subcents, as: :value, with_currency: :brl
  monetize :cost_value_subcents, as: :cost_value, with_currency: :brl

  validates :quantity, presence: true
  validate :validate_product_quantity, if: -> { will_save_change_to_quantity? }

  after_save :recalculate_values, if: -> { saved_change_to_quantity? || saved_change_to_value_subcents? }
  after_destroy :recalculate_values

  before_create :set_default_fields

  def total_value
    self.value * self.quantity
  end

  def recalculate_values
    self.order.recalculate_values
    self.order.calculate_comissions

    self.order.save
  end

  private

  def set_default_fields
    company_config = self.order.company.company_config
    self.value = company_config.calculate_product_value(self.stock.product.value)
    self.cost_value = self.stock.product.cost_value
  end

  def validate_product_quantity
    if self.quantity > self.stock.quantity
      self.errors.add(:quantity, "Quantidade insuficiente")
    end
  end
end
