class CreatePayments < ActiveRecord::Migration[8.1]
  def up
    create_table :payments do |t|
      t.references :payment_method, null: true, foreign_key: true
      t.monetize :value, null: false, default: 0
      t.monetize :taxes_value, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :payments
  end
end
