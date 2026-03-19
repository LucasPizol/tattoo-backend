class AddRoleToUser < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :role, foreign_key: true
    remove_column :users, :role, :integer
  end
end
