class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :indications_orders, null: false, default: 0
      t.integer :campaing_type, null: false, default: 0, index: true
      t.boolean :active, null: false, default: true

      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
