class AddStockToOrderProduct < ActiveRecord::Migration[8.1]
  def change
    add_reference :order_products, :stock, foreign_key: true, null: true

    stocks = Stock.all
    order_products = OrderProduct.all

    order_products.each do |order_product|
      order_product.update!(stock: stocks.select { |stock| stock.product_id == order_product.product_id }.first)
    end

    remove_reference :order_products, :product, foreign_key: true, null: true
  end
end
