class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :name
      t.string :street
      t.string :neighborhood
      t.string :zipcode
      t.string :city
      t.string :state
      t.string :number
      t.string :complement
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
