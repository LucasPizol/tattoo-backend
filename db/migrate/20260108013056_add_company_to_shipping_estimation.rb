class AddCompanyToShippingEstimation < ActiveRecord::Migration[8.1]
  def change
    add_column :shipping_estimations, :company, :string, null: false, default: ""
  end
end
