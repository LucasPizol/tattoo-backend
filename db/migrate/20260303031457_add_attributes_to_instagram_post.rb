class AddAttributesToInstagramPost < ActiveRecord::Migration[8.1]
  def change
    change_table :instagram_posts, bulk: true do |t|
      t.string  :ig_media_url
      t.string  :ig_media_type
      t.integer :ig_comments_count
      t.integer :ig_like_count
      t.string  :ig_media_product_type
      t.string  :ig_thumbnail_url
      t.string  :ig_username
      t.integer :ig_view_count
    end

    add_index :instagram_posts, :ig_media_id, unique: true
    add_index :instagram_posts, :ig_media_type
    add_index :instagram_posts, :ig_media_product_type
    add_index :instagram_posts, :ig_username
    add_index :instagram_posts, :status
  end
end
