class RenameUsersToCompany < ActiveRecord::Migration[8.1]
  def change
    user = User.last

    rename_table :users, :companies
    rename_table :user_configs, :company_configs

    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false
      t.string :username, null: false
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    remove_column :companies, :email
    remove_column :companies, :refresh_token
    remove_column :companies, :refresh_token_expires_at
    remove_column :companies, :role
    remove_column :companies, :username
    remove_column :companies, :password_digest
  end
end
