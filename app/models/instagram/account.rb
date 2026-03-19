# == Schema Information
#
# Table name: instagram_accounts
#
#  id                     :bigint           not null, primary key
#  company_account        :boolean          default(FALSE), not null
#  ig_access_token        :string           not null
#  ig_expires_at          :datetime         not null
#  ig_profile_picture_url :string           not null
#  ig_username            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer          not null
#  ig_id                  :string           not null
#  user_id                :integer
#
# Indexes
#
#  index_instagram_accounts_on_company_id  (company_id)
#  index_instagram_accounts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
class Instagram::Account < ApplicationRecord
  self.table_name = "instagram_accounts"
  encrypts :ig_access_token
  encrypts :ig_profile_picture_url
  encrypts :ig_username

  belongs_to :company
  has_many :posts, dependent: :destroy, class_name: "Instagram::Post", foreign_key: :instagram_account_id, primary_key: :id

  validates :ig_id, presence: true
  validates :ig_username, presence: true

  before_save :set_ig_profile_picture_url, if: -> { ig_profile_picture_url.blank? }

  private

  def set_ig_profile_picture_url
    self.ig_profile_picture_url = ""
  end
end
