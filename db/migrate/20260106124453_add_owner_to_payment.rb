class AddOwnerToPayment < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :owner, :integer, null: true, default: 0
  end
end
