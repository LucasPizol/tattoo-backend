class RenameCategoriesToTags < ActiveRecord::Migration[8.1]
  def change
    rename_table :categories, :tags
    rename_table :product_categories, :product_tags

    rename_column :tags, :category_id, :tag_id
    rename_column :product_tags, :category_id, :tag_id

    reversible do |dir|
      dir.up do
        execute "UPDATE permissions SET name = REPLACE(name, 'categories.', 'tags.') WHERE name LIKE 'categories.%'"
      end
      dir.down do
        execute "UPDATE permissions SET name = REPLACE(name, 'tags.', 'categories.') WHERE name LIKE 'tags.%'"
      end
    end
  end
end
