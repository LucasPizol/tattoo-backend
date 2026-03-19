class AddUserIdToClient < ActiveRecord::Migration[8.1]
  def change
    add_reference :clients, :user, null: true, foreign_key: true
    add_reference :categories, :user, null: true, foreign_key: true
    add_reference :materials, :user, null: true, foreign_key: true
    add_reference :payment_methods, :user, null: true, foreign_key: true
  end
end
