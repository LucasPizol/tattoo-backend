class CreateComissions< ActiveRecord::Migration[8.1]
  def change
    create_table :comissions do |t|
      t.string :name, null: false
      t.string :percentage, null: false
      t.monetize :value, default: 0, null: false
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
