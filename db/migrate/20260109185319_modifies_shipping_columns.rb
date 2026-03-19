class ModifiesShippingColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :shippings, :cost_cents, :profitable_value_cents
    rename_column :shippings, :cost_currency, :profitable_value_currency

    rename_column :shippings, :shipping_estimation_value_cents, :original_value_cents
    rename_column :shippings, :shipping_estimation_value_currency, :original_value_currency
  end
end
