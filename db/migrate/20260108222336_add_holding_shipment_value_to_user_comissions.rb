class AddHoldingShipmentValueToUserComissions < ActiveRecord::Migration[8.1]
  def change
    change_table :user_comissions, bulk: true do |t|
      t.monetize :holding_shipment_value, default: 0, null: false
    end
  end
end
