class AddLocalPickupToOrder < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :local_pickup, :boolean, default: false
  end
end
