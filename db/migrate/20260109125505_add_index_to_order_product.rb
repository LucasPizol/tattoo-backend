class AddIndexToOrderProduct < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :order_products, [ :order_id, :stock_id ], unique: true, algorithm: :concurrently
  end
end
