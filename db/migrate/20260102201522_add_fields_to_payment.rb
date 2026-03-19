class AddFieldsToPayment < ActiveRecord::Migration[8.1]
  def change
    add_reference :payments, :order, null: true, foreign_key: true
    add_column :payments, :installments, :string, null: true
    add_column :payments, :cardholder_name, :string, null: true
    add_column :payments, :last_four_digits, :string, null: true
    add_column :payments, :payment_type, :string, null: true
  end
end
