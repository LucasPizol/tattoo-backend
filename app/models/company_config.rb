# == Schema Information
#
# Table name: company_configs
#
#  id                             :bigint           not null, primary key
#  birth_date_discount_percentage :integer          default(0), not null
#  product_percentage_variation   :integer          default(0), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  company_id                     :integer          not null
#
# Indexes
#
#  index_company_configs_on_company_id  (company_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class CompanyConfig < ApplicationRecord
  belongs_to :company

  validates :birth_date_discount_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :product_percentage_variation, presence: true, numericality: { greater_than_or_equal_to: -100, less_than_or_equal_to: 100 }

  def calculate_product_value(product_value)
    return product_value if product_percentage_variation.zero?

    product_value + (product_value * product_percentage_variation / 100.0)
  end
end
