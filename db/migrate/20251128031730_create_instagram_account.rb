class CreateInstagramAccount < ActiveRecord::Migration[8.1]
  def change
    create_table :instagram_accounts do |t|
      t.string :ig_id, null: false
      t.string :ig_username
      t.string :ig_profile_picture_url, null: false
      t.string :ig_access_token, null: false
      t.datetime :ig_expires_at, null: false
      t.references :company, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.boolean :company_account, null: false, default: false

      t.timestamps
    end
  end
end
