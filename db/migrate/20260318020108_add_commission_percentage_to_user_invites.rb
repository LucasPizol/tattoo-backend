class AddCommissionPercentageToUserInvites < ActiveRecord::Migration[8.1]
  def change
    add_column :user_invites, :commission_percentage, :decimal, precision: 5, scale: 2, default: 0, null: false
  end
end
