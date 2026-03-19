class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.integer :status, null: false, default: 0
      t.references :client, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.integer :product_values_subcents, null: false, default: 0
      t.string :product_values_currency, null: false, default: "br"
      t.integer :taxes_values_subcents, null: false, default: 0
      t.string :taxes_values_currency, null: false, default: "br"
      t.references :payment_method, null: true, foreign_key: true
      t.references :address, null: true, foreign_key: true

      t.timestamps
    end
  end
end
