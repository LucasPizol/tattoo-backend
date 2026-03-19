class AddRefreshTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :refresh_token, null: true
      t.datetime :refresh_token_expires_at, null: true
    end
  end
end
