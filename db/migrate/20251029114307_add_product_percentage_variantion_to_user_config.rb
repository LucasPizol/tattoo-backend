class AddProductPercentageVariantionToUserConfig < ActiveRecord::Migration[8.1]
  def change
    add_column :user_configs, :product_percentage_variation, :integer, null: false, default: 0
  end
end
