# == Schema Information
#
# Table name: addresses
#
#  id           :bigint           not null, primary key
#  address_type :integer          default("home")
#  city         :string
#  complement   :string
#  favorite     :boolean          default(FALSE)
#  name         :string
#  neighborhood :string
#  number       :string
#  state        :string
#  street       :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  client_id    :integer          not null
#
# Indexes
#
#  index_addresses_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class Address < ApplicationRecord
  belongs_to :client

  enum :address_type, { home: 0, work: 1, other: 2 }
end
