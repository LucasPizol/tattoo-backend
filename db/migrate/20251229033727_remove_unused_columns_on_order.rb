class RemoveUnusedColumnsOnOrder < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :iris_part_cents, :integer, default: 0, null: false
    remove_column :orders, :iris_part_currency, :string, default: "BRL"
    remove_column :orders, :jennipher_part_cents, :integer, default: 0, null: false
    remove_column :orders, :jennipher_part_currency, :string, default: "BRL"
    remove_column :orders, :payment_method_id, :integer
    add_column :orders, :values_divided, :boolean, default: false, null: false
  end
end
