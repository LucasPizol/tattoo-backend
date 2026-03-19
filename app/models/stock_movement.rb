# == Schema Information
#
# Table name: stock_movements
#
#  id             :bigint           not null, primary key
#  movement_type  :string           default("in"), not null
#  notes          :string
#  quantity       :integer          not null
#  value_currency :string           default("br"), not null
#  value_subcents :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  company_id     :integer          not null
#  order_id       :integer
#  stock_id       :bigint
#
# Indexes
#
#  index_stock_movements_on_company_id  (company_id)
#  index_stock_movements_on_order_id    (order_id)
#  index_stock_movements_on_stock_id    (stock_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (stock_id => stocks.id)
#
class StockMovement < ApplicationRecord
  belongs_to :stock
  belongs_to :company
  belongs_to :order, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :value_subcents, presence: true
  validates :value_currency, presence: true
  validates :movement_type, presence: true

  after_save :update_stock_quantity, if: -> { saved_change_to_quantity? }
  after_destroy :update_stock_quantity_after_destroy

  monetize :value_subcents, as: :value, with_currency: :brl

  enum :movement_type, {
    in: "in",
    out: "out"
  }

  private

  def update_stock_quantity_after_destroy
    stock = self.stock

    stock.quantity = stock.quantity - self.quantity if self.in?
    stock.quantity = stock.quantity + self.quantity if self.out?

    stock.save!(validate: false)
  end

  def update_stock_quantity
    stock = self.stock

    stock.quantity = stock.quantity + self.quantity if self.in?
    stock.quantity = stock.quantity - self.quantity if self.out?

    stock.save!
  end
end
