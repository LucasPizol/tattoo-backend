class CreateUserClients < ActiveRecord::Migration[8.0]
  def change
    create_table :user_clients do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :name, null: false
      t.references :client, null: false, foreign_key: true
      t.string :authentication_type, null: false, default: 'email'

      t.timestamps

      t.index :email, unique: true
      t.index :authentication_type
    end
  end
end
