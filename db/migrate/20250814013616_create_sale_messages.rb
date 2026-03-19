class CreateSaleMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :sale_messages do |t|
      t.references :order, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.string :status

      t.timestamps
    end
  end
end
