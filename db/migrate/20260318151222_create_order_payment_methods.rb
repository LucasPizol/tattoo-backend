class CreateOrderPaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :order_payment_methods do |t|
      t.references :order, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true

      t.monetize :value, null: false, default: 0

      t.index [ :order_id, :payment_method_id ], unique: true

      t.timestamps
    end
  end
end
