class CreateUserInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :user_invites do |t|
      t.string :phone
      t.integer :status, default: 0, null: false
      t.references :company, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
