# == Schema Information
#
# Table name: contracts
#
#  id                :bigint           not null, primary key
#  content           :text             not null
#  signed_at         :datetime
#  signer_ip         :string
#  signer_user_agent :string
#  status            :integer          default("pending"), not null
#  version           :integer          default(1), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_contracts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Contract < ApplicationRecord
  belongs_to :user
  has_one_attached :signature

  enum :status, {
    pending: 0,
    signed: 1,
  }

  validates :content, presence: true
  validates :version, presence: true
end
