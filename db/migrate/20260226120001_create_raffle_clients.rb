class CreateRaffleClients < ActiveRecord::Migration[8.1]
  def change
    create_table :raffle_clients do |t|
      t.bigint :raffle_id, null: false
      t.integer :client_id, null: false
      t.integer :raffle_type, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :raffle_clients, :raffle_id
    add_index :raffle_clients, :client_id
    add_index :raffle_clients, [ :raffle_id, :client_id ]
    add_foreign_key :raffle_clients, :raffles
    add_foreign_key :raffle_clients, :clients
  end
end
