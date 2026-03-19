class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :name
      t.string :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
