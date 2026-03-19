# == Schema Information
#
# Table name: clients
#
#  id                            :bigint           not null, primary key
#  allergic_reactions            :boolean          default(FALSE)
#  birth_date                    :date
#  cpf                           :string
#  diabetes                      :boolean          default(FALSE)
#  disease_infectious_contagious :boolean          default(FALSE)
#  email                         :string
#  encrypted_password            :string
#  epilepsy                      :boolean          default(FALSE)
#  gender                        :string
#  healing_problems              :boolean          default(FALSE)
#  hemophilia                    :boolean          default(FALSE)
#  high_blood_pressure           :boolean          default(FALSE)
#  hipoglycemia                  :boolean          default(FALSE)
#  hypersensitivity_to_chemicals :boolean          default(FALSE)
#  indicated_at                  :datetime
#  instagram_profile             :string
#  keloid_proneness              :boolean          default(FALSE)
#  low_blood_pressure            :boolean          default(FALSE)
#  marital_status                :string
#  name                          :string
#  observations                  :text
#  pacemaker                     :boolean          default(FALSE)
#  phone                         :string
#  rg                            :string
#  vitiligo                      :boolean          default(FALSE)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  company_id                    :integer          not null
#  indicated_by_id               :integer
#  user_id                       :bigint
#
# Indexes
#
#  index_clients_on_company_id       (company_id)
#  index_clients_on_cpf_and_user_id  (cpf,user_id) UNIQUE
#  index_clients_on_indicated_by_id  (indicated_by_id)
#  index_clients_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (indicated_by_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class ClientTest < ActiveSupport::TestCase
  should validate_presence_of :name

  test "age" do
    client = clients(:one)
    assert_equal 36, client.age
  end
end
