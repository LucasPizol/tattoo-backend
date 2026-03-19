class CreateUserInviteTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :user_invite_tokens do |t|
      t.references :user_invite, null: false, foreign_key: true
      t.string :token
      t.boolean :enabled, default: false, null: false

      t.timestamps
    end
  end
end
