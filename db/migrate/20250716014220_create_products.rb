class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.bigint :value_subcents, null: false, default: 0
      t.string :value_currency, null: false, default: "brl"
      t.references :material, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :sku, null: false

      t.timestamps

      t.index :sku, unique: true
      t.index [ :user_id, :sku ], unique: true
      t.index [ :material_id, :sku ], unique: true
    end
  end
end
