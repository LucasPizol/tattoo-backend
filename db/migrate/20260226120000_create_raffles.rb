class CreateRaffles < ActiveRecord::Migration[8.1]
  def change
    create_table :raffles do |t|
      t.string :name, null: false
      t.text :description
      t.integer :company_id, null: false
      t.integer :primary_count, null: false, default: 1
      t.integer :secondary_count, null: false, default: 0
      t.jsonb :filters, null: false, default: {}

      t.timestamps
    end

    add_index :raffles, :company_id
    add_foreign_key :raffles, :companies
  end
end
