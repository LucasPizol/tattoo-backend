class CreateStock < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end
  end
end
