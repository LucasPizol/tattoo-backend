class AddFavoriteAndAddressTypeToAddress < ActiveRecord::Migration[8.1]
  def change
    add_column :addresses, :favorite, :boolean, default: false
    add_column :addresses, :address_type, :integer, default: 0
  end
end
