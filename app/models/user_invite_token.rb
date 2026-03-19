# == Schema Information
#
# Table name: user_invite_tokens
#
#  id             :bigint           not null, primary key
#  enabled        :boolean          default(FALSE), not null
#  token          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_invite_id :bigint           not null
#
# Indexes
#
#  index_user_invite_tokens_on_user_invite_id  (user_invite_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_invite_id => user_invites.id)
#
class UserInviteToken < ApplicationRecord
  belongs_to :user_invite

  encrypts :token, deterministic: true
end
