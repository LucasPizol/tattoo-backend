# == Schema Information
#
# Table name: comissions
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  payer          :string           default("user"), not null
#  percentage     :decimal(5, 2)    default(0.0), not null
#  value_cents    :integer          default(0), not null
#  value_currency :string           default("BRL")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  order_id       :integer          not null
#  user_id        :bigint
#
# Indexes
#
#  index_comissions_on_order_id  (order_id)
#  index_comissions_on_payer     (payer)
#  index_comissions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (user_id => users.id)
#
class Comission < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :name, presence: true
  validates :percentage, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: -> { value.present? }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: -> { percentage.present? }

  monetize :value_cents, as: :value, with_currency: :brl

  def calculate_value
    self.value = (order.product_value * (self.percentage.to_f / 100)).to_money
  end

  def calculate_percentage
    return self.percentage = 0 if self.value.zero? || order.product_value.zero?

    self.percentage = ((self.value / order.product_value) * 100).to_f.round(2)
  end
end
