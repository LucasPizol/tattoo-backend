class AddCostValueToProduct < ActiveRecord::Migration[8.0]
  def change
    change_table :products, bulk: true do |t|
      t.integer :cost_value_subcents, default: 0
      t.string :cost_value_currency, default: 'br'

      t.index :cost_value_subcents, name: 'index_products_on_cost_value_subcents'
      t.index :cost_value_currency, name: 'index_products_on_cost_value_currency'
    end
  end
end
