# == Schema Information
#
# Table name: materials
#
#  id         :bigint           not null, primary key
#  name       :string
#  notes      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#  user_id    :bigint
#
# Indexes
#
#  index_materials_on_company_id  (company_id)
#  index_materials_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
class Material < ApplicationRecord
  belongs_to :company
  has_many :products, dependent: :destroy

  validates :name, presence: true

  scope :with_products, -> { where(id: Product.featured.with_images.select(:material_id)) }

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end

  def format
    {
      id: self.id,
      name: self.name,
      notes: self.notes,
      createdAt: self.created_at,
      updatedAt: self.updated_at
    }
  end
end
