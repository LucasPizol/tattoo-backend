class AddPermalinkToInstagram < ActiveRecord::Migration[8.1]
  def change
    add_column :instagram_posts, :ig_permalink, :string
  end
end
