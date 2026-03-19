class AddOrderToStockMovement < ActiveRecord::Migration[8.1]
  def change
    add_reference :stock_movements, :order, foreign_key: true, null: true
  end
end
