class AddComissionsValueToOrder < ActiveRecord::Migration[8.1]
  def change
    change_table :orders, bulk: true do |t|
      t.monetize :comissions_value, default: 0, null: false

      t.change :product_values_currency, :string, default: "BRL"
      t.change :cost_value_currency, :string, default: "BRL"
      t.change :taxes_values_currency, :string, default: "BRL"
      t.change :iris_part_currency, :string, default: "BRL"
      t.change :jennipher_part_currency, :string, default: "BRL"
    end

    change_table :comissions, bulk: true do |t|
      t.change :value_currency, :string, default: "BRL"
    end
  end
end
