class ModifyStockMovementRelation < ActiveRecord::Migration[8.1]
  def change
    add_reference :stock_movements, :stock, foreign_key: true, null: true

    Product.all.each do |product|
      stock = Stock.create!(product: product, user_id: product.user&.id || User::ACCOUNT_OWNER_ID, quantity: product.quantity)
      StockMovement.where(product_id: product.id).update_all(stock_id: stock.id)
    end

    remove_reference :stock_movements, :product, foreign_key: true, null: true
    remove_column :products, :quantity, :integer
  end
end
