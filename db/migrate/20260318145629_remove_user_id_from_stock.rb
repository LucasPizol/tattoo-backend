class RemoveUserIdFromStock < ActiveRecord::Migration[8.1]
  def change
    remove_reference :stocks, :user, foreign_key: true
  end
end
