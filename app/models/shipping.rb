# == Schema Information
#
# Table name: shippings
#
#  id                        :bigint           not null, primary key
#  company                   :string           not null
#  delivered_at              :datetime
#  estimated_at              :datetime         not null
#  estimated_delivery        :string           not null
#  original_value_cents      :integer          default(0), not null
#  original_value_currency   :string           default("BRL"), not null
#  profitable_value_cents    :integer          default(0), not null
#  profitable_value_currency :string           default("BRL"), not null
#  status                    :integer          default("pending"), not null
#  tracking_number           :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  order_id                  :bigint           not null
#
# Indexes
#
#  index_shippings_on_order_id         (order_id)
#  index_shippings_on_tracking_number  (tracking_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class Shipping < ApplicationRecord
  ESTIMATION_VALIDITY_TIME = 1.hour

  belongs_to :order

  monetize :profitable_value_cents, as: :profitable_value, with_currency: :brl
  monetize :original_value_cents, as: :original_value, with_currency: :brl

  enum :status, {
    pending: 0,
    in_progress: 1,
    delivered: 2,
    canceled: 3
  }

  def calculate_cost
    if self.order.address.present?
      self.profitable_value_cents = rand(10..100) * 100
      self.estimated_at = Time.current
      self.estimated_delivery = "2 dias úteis"
      self.company = "Correios"
    else
      self.profitable_value_cents = 0
    end
  end

  def estimation_valid?
    self.order.address.present? && (self.estimated_at.blank? || self.estimated_at > ESTIMATION_VALIDITY_TIME.ago)
  end

  def estimation_invalid?
    !estimation_valid?
  end

  def profit
     self.profitable_value - self.original_value
  end
end
