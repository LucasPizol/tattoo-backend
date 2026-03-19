class OrderPayment < ApplicationRecord
  belongs_to :order
  belongs_to :user
  belongs_to :payment_expected, class_name: "Client::Payment", foreign_key: "payment_expected_id"
  belongs_to :payment_received, class_name: "Client::Payment", foreign_key: "payment_received_id"
end

class CreateUserComission < ActiveRecord::Migration[8.1]
  def change
    create_table :user_comissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payment_method, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.monetize :comission_value, null: false, default: 0
      t.monetize :received_value, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    OrderPayment.find_each do |order_payment|
      UserComission.create!(
        user: order_payment.user,
        payment_method_id: order_payment.payment_expected&.payment_method_id,
        order: order_payment.order,
        comission_value: order_payment.payment_expected&.value,
        received_value: order_payment.payment_received&.value,
        status: :paid
      )

      payment_expected = order_payment.payment_expected
      payment_received = order_payment.payment_received

      order_payment.delete
      payment_expected.delete
      payment_received.delete
    end
  end
end
