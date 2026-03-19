class AddErrorMessageToInstagramPost < ActiveRecord::Migration[8.1]
  def change
    add_column :instagram_posts, :error_message, :text
  end
end
