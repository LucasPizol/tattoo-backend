class AddAppliedBirthDateDiscountPercentage < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :applied_birth_date_discount_percentage, :integer, null: false, default: 0
  end
end
