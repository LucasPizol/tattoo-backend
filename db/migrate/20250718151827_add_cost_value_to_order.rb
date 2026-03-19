class AddCostValueToOrder < ActiveRecord::Migration[8.0]
  def change
    change_table :orders, bulk: true do |t|
      t.integer :cost_value_subcents, default: 0, null: false
      t.string :cost_value_currency, default: "BRL", null: false
    end

    change_table :order_products, bulk: true do |t|
      t.integer :cost_value_subcents, default: 0, null: false
      t.string :cost_value_currency, default: "BRL", null: false
    end
  end
end
