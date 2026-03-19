class AddInstagramToRaffleClient < ActiveRecord::Migration[8.1]
  def change
    add_reference :raffle_clients, :instagram_comment, null: true, foreign_key: true
    change_column_null :raffle_clients, :client_id, true
  end
end
