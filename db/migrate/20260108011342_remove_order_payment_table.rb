class RemoveOrderPaymentTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :order_payments
  end
end
