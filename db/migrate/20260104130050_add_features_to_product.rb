class AddFeaturesToProduct < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.references :user, null: true, foreign_key: true
      t.boolean :featured, null: false, default: false
      t.boolean :new, null: false, default: false
      t.boolean :carousel, null: false, default: false
    end

    Product.update_all(featured: true)
  end
end
