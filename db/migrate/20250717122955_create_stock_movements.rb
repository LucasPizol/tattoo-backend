class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :value_subcents, null: false
      t.string :value_currency, null: false, default: 'br'

      t.string :movement_type, null: false, default: 'in'
      t.string :notes
      t.references :user, null: false, foreign_key: true

      t.index [ :product_id, :movement_type ]

      t.timestamps
    end
  end
end
