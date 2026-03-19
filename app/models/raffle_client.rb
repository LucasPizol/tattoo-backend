# == Schema Information
#
# Table name: raffle_clients
#
#  id                   :bigint           not null, primary key
#  position             :integer          default(0), not null
#  raffle_type          :integer          default("primary"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :integer
#  instagram_comment_id :bigint
#  raffle_id            :bigint           not null
#
# Indexes
#
#  index_raffle_clients_on_client_id                (client_id)
#  index_raffle_clients_on_instagram_comment_id     (instagram_comment_id)
#  index_raffle_clients_on_raffle_id                (raffle_id)
#  index_raffle_clients_on_raffle_id_and_client_id  (raffle_id,client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (instagram_comment_id => instagram_comments.id)
#  fk_rails_...  (raffle_id => raffles.id)
#
class RaffleClient < ApplicationRecord
  belongs_to :raffle
  belongs_to :client, optional: true
  belongs_to :instagram_comment, optional: true, inverse_of: :raffle_clients, class_name: "Instagram::Comment", foreign_key: :instagram_comment_id, primary_key: :id

  enum :raffle_type, { primary: 0, secondary: 1 }

  validates :position, numericality: { greater_than: 0 }
end
