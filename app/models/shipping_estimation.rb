# == Schema Information
#
# Table name: shipping_estimations
#
#  id                  :bigint           not null, primary key
#  company             :string           default(""), not null
#  cost_cents          :integer          default(0), not null
#  cost_currency       :string           default("BRL"), not null
#  estimated_delivery  :string           not null
#  final_cost_cents    :integer          default(0), not null
#  final_cost_currency :string           default("BRL"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_id            :bigint           not null
#
# Indexes
#
#  index_shipping_estimations_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class ShippingEstimation < ApplicationRecord
  TAXES_PERCENTAGE = 0.05

  belongs_to :order

  monetize :cost_cents, as: :cost, with_currency: :brl
  monetize :final_cost_cents, as: :final_cost, with_currency: :brl

  def calculate_final_cost
    (self.final_cost * (1 + TAXES_PERCENTAGE))
  end

  def self.calculate_cost(order)
    if order.shipping_estimations.any?
      return order.shipping_estimations
    end

    values = Shipping::CostService.run!(order).map do |value|
      {
        order_id: order.id,
        cost_cents: value[:cost].cents,
        cost_currency: value[:cost].currency.id,
        final_cost_cents: value[:final_cost].cents,
        final_cost_currency: value[:final_cost].currency.id,
        estimated_delivery: value[:estimated_delivery],
        company: value[:company]
      }
    end

    ShippingEstimation.insert_all(values)

    order.shipping_estimations.order(final_cost_cents: :asc)
  end
end
