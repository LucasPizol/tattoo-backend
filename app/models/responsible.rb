# == Schema Information
#
# Table name: responsibles
#
#  id         :bigint           not null, primary key
#  birth_date :date             not null
#  cpf        :string           not null
#  email      :string
#  gender     :string           not null
#  name       :string           not null
#  phone      :string           not null
#  rg         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :integer          not null
#
# Indexes
#
#  index_responsibles_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class Responsible < ApplicationRecord
  belongs_to :client

  validates :name, :phone, :birth_date, :gender, :cpf, presence: true

  normalizes :email, with: ->(value) { value&.downcase&.strip }
  normalizes :cpf, with: ->(value) { value.gsub(/\D/, "") }
  normalizes :phone, with: ->(value) { value.gsub(/\D/, "") }
  normalizes :rg, with: ->(value) { value&.gsub(/\D/, "") }
  normalizes :birth_date, with: ->(value) { value.to_date }
  normalizes :gender, with: ->(value) { value.downcase.strip }
  normalizes :name, with: ->(value) { value.strip }

  def first_name
    name.split(" ").first.strip.capitalize
  end
end
