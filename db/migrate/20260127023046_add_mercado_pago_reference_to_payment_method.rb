class AddMercadoPagoReferenceToPaymentMethod < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_methods, :external_type, :integer, null: false, default: 0
  end
end
