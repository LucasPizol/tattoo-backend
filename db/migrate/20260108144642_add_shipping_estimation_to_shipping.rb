class AddShippingEstimationToShipping < ActiveRecord::Migration[8.1]
  def change
    change_table :shippings, bulk: true do |t|
      t.monetize :shipping_estimation_value, null: false, default: 0
    end
  end
end
