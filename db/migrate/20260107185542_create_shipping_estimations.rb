class CreateShippingEstimations < ActiveRecord::Migration[8.1]
  def change
    create_table :shipping_estimations do |t|
      t.monetize :cost, null: false
      t.monetize :final_cost, null: false
      t.string :estimated_delivery, null: false
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
