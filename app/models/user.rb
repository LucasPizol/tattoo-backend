# == Schema Information
#
# Table name: users
#
#  id                       :bigint           not null, primary key
#  color                    :string
#  commission_percentage    :decimal(5, 2)    default(0.0), not null
#  google_uid               :string
#  name                     :string           not null
#  password_digest          :string           not null
#  refresh_token            :string
#  refresh_token_expires_at :datetime
#  refresh_token_issued_at  :datetime
#  text_color               :string
#  username                 :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  company_id               :integer          not null
#  role_id                  :bigint
#
# Indexes
#
#  index_users_on_company_id                                  (company_id)
#  index_users_on_google_uid                                  (google_uid) UNIQUE
#  index_users_on_refresh_token                               (refresh_token) UNIQUE
#  index_users_on_refresh_token_and_refresh_token_expires_at  (refresh_token,refresh_token_expires_at)
#  index_users_on_refresh_token_expires_at                    (refresh_token_expires_at)
#  index_users_on_role_id                                     (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (role_id => roles.id)
#
class User < ApplicationRecord
  ACCOUNT_OWNER_ID = 1

  has_secure_password
  encrypts :refresh_token, deterministic: true

  validates :username, presence: true
  validates :name, presence: true
  validates :google_uid, uniqueness: true, allow_nil: true
  validates :commission_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  belongs_to :company
  has_one :company_config, through: :company
  belongs_to :role, optional: true
  has_many :permissions, through: :role
  has_many :contracts, dependent: :destroy
  has_many :clients, dependent: :destroy

  def generate_refresh_token
    update!(refresh_token: SecureRandom.hex(32), refresh_token_expires_at: 7.days.from_now, refresh_token_issued_at: Time.current)
  end

  def self.find_by_refresh_token(refresh_token)
    where("refresh_token_expires_at > ?", Time.current).find_by(refresh_token: refresh_token)
  end

  def root?
    self.id == User::ACCOUNT_OWNER_ID
  end

  def can?(method, resource)
    permitted?(method, resource)
  end

  def cannot?(method, resource)
    !can?(method, resource)
  end

  def pays_comissions?
    self.commission_percentage.positive?
  end

  def comissionable?
    self.commission_percentage.negative?
  end

  private

  def permitted?(method, resource)
    permissions.any? { |permission| permission.name == "#{resource.name.tableize}.#{method}" }
  end
end
