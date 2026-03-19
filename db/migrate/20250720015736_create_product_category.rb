class CreateProductCategory < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.timestamps

      t.index [ :product_id, :category_id ], unique: true
    end
  end
end
