class AddDescriptionToProduct < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.text :description
    end
  end
end
