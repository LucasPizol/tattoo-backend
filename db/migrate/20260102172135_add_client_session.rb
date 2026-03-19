class AddClientSession < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :encrypted_password, :string, null: true
  end
end
