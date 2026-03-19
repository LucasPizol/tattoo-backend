# == Schema Information
#
# Table name: user_invites
#
#  id                    :bigint           not null, primary key
#  commission_percentage :decimal(5, 2)    default(0.0), not null
#  phone                 :string
#  status                :integer          default("pending"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  company_id            :bigint           not null
#  role_id               :bigint           not null
#
# Indexes
#
#  index_user_invites_on_company_id  (company_id)
#  index_user_invites_on_role_id     (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (role_id => roles.id)
#
class UserInvite < ApplicationRecord
  belongs_to :company
  belongs_to :role
  has_many :user_invite_tokens, dependent: :destroy

  validates :phone, presence: true
  validates :commission_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  normalizes :phone, with: ->(value) do
    normalized_value = value.gsub(/[^0-9]/, "")

    if normalized_value.length == 11
      "55#{normalized_value}"
    else
      normalized_value
    end
  end

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2
  }
end
