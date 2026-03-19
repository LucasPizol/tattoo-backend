# == Schema Information
#
# Table name: payment_methods
#
#  id            :bigint           not null, primary key
#  external_type :integer          default("credit_card"), not null
#  name          :string           not null
#  taxes         :float            default(0.0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :integer          not null
#  user_id       :bigint
#
# Indexes
#
#  index_payment_methods_on_company_id  (company_id)
#  index_payment_methods_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
class PaymentMethod < ApplicationRecord
  belongs_to :company
  has_many :order_payment_methods, dependent: :destroy

  validates :name, presence: true
  validates :taxes, presence: true

  enum :external_type, {
    credit_card: 0,
    debit_card: 1,
    qr: 2,
    voucher_card: 3,
    cash: 4
  }
end
