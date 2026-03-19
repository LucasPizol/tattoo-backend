class CreateCartProduct < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_products do |t|
      t.references :client, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :value_subcents, null: false, default: 0
      t.string :value_currency, null: false, default: "brl"

      t.timestamps
    end
  end
end
