# == Schema Information
#
# Table name: order_payment_methods
#
#  id                :bigint           not null, primary key
#  value_cents       :integer          default(0), not null
#  value_currency    :string           default("BRL"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  order_id          :bigint           not null
#  payment_method_id :bigint           not null
#
# Indexes
#
#  index_order_payment_methods_on_order_id                        (order_id)
#  index_order_payment_methods_on_order_id_and_payment_method_id  (order_id,payment_method_id) UNIQUE
#  index_order_payment_methods_on_payment_method_id               (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#
class OrderPaymentMethod < ApplicationRecord
  belongs_to :order
  belongs_to :payment_method

  monetize :value_cents, as: :value, with_currency: :brl
end
