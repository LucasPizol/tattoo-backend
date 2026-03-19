class CreateInstagramPost < ActiveRecord::Migration[8.1]
  def change
    create_table :instagram_posts do |t|
      t.string :caption, null: false
      t.references :instagram_account, null: false, foreign_key: true

      t.string :status, null: false, default: 'draft'
      t.datetime :published_at

      t.string :ig_container_id, null: true
      t.string :ig_carousel_id, null: true
      t.string :ig_media_id, null: true

      t.timestamps
    end
  end
end
