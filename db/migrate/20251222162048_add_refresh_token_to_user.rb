class AddRefreshTokenToUser < ActiveRecord::Migration[8.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :refresh_token, null: true, index: { unique: true }
      t.datetime :refresh_token_issued_at, null: true
      t.datetime :refresh_token_expires_at, null: true, index: true

      t.index [ :refresh_token, :refresh_token_expires_at ]
    end
  end
end
