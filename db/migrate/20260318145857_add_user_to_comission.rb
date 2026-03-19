class AddUserToComission < ActiveRecord::Migration[8.1]
  def up
    add_reference :comissions, :user, foreign_key: true
    add_column    :comissions, :payer, :string, null: false, default: "user"
    add_index     :comissions, :payer
  end

  def down
    remove_reference :comissions, :user
    remove_column :comissions, :payer
    remove_index  :comissions, :payer
  end
end
