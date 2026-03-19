class CreateShipping < ActiveRecord::Migration[8.1]
  def change
    create_table :shippings do |t|
      t.references :order, null: false, foreign_key: true

      t.string :company, null: false
      t.string :tracking_number, null: true
      t.monetize :cost, null: true
      t.string :estimated_delivery, null: false
      t.datetime :delivered_at, null: true
      t.datetime :estimated_at, null: false
      t.integer :status, null: false, default: 0

      t.index :tracking_number, unique: true

      t.timestamps
    end
  end
end
