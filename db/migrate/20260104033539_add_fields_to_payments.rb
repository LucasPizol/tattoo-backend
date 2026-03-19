class AddFieldsToPayments < ActiveRecord::Migration[8.1]
  def change
    change_table :payments, bulk: true do |t|
      t.monetize :net_received_value, null: true, default: 0
      t.monetize :total_paid_amount, null: true, default: 0
      t.monetize :installment_amount, null: true, default: 0
      t.bigint :external_id, null: true
    end
  end
end
