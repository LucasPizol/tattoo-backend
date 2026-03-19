class CreateInstagramComments < ActiveRecord::Migration[8.1]
  def change
    create_table :instagram_comments do |t|
      t.references :instagram_post, null: false, foreign_key: true
      t.references :instagram_account, null: false, foreign_key: true
      t.references :instagram_comment, null: true, foreign_key: true

      t.text :text, null: false
      t.string :username

      t.string :ig_comment_id, null: false

      t.timestamps
    end
  end
end
