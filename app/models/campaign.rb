# == Schema Information
#
# Table name: campaigns
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(TRUE), not null
#  campaing_type      :integer          default("indications"), not null
#  description        :text             not null
#  indications_orders :integer          default(0), not null
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  company_id         :integer          not null
#
# Indexes
#
#  index_campaigns_on_campaing_type  (campaing_type)
#  index_campaigns_on_company_id     (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class Campaign < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :description, presence: true
  validates :indications_orders, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum :campaing_type, { indications: 0, referral: 1 }

  scope :active, -> { where(active: true) }
end
