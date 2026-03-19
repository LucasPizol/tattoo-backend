class CreateOrderProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :order_products do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :value_subcents, null: false, default: 0
      t.string :value_currency, null: false, default: "br"

      t.timestamps
    end
  end
end
