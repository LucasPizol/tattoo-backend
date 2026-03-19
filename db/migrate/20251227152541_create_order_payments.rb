class CreateOrderPayments < ActiveRecord::Migration[8.1]
  def up
    create_table :order_payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.references :payment_expected, null: false, foreign_key: true, foreign_key: { to_table: :payments }
      t.references :payment_received, null: false, foreign_key: true, foreign_key: { to_table: :payments }

      t.index [ :order_id, :user_id ], unique: true

      t.timestamps
    end

    iris_user = User.find_by(username: "iris")
    jennipher_user = User.find_by(username: "jenipher")

    Payment.skip_callback(:save, :before, :calculate_taxes_value)

    Order.find_each do |order|
      iris_payment = Payment.create!(
        payment_method_id: order.payment_method_id,
        value_cents: order.iris_part_cents,
        status: :paid
      )

      jennipher_payment = Payment.create!(
        payment_method_id: order.payment_method_id,
        value_cents: order.jennipher_part_cents,
        status: :paid
      )

      OrderPayment.create!(
        order: order,
        user: iris_user,
        payment_expected: iris_payment,
        payment_received: iris_payment
      )
      OrderPayment.create!(
        order: order,
        user: jennipher_user,
        payment_expected: jennipher_payment,
        payment_received: jennipher_payment
      )
    end

    Payment.set_callback(:save, :before, :calculate_taxes_value)
  end

  def down
    drop_table :order_payments
  end
end
