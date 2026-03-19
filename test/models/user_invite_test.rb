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
require "test_helper"

class UserInviteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
