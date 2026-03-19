class CreateResponsible < ActiveRecord::Migration[8.0]
  def change
    create_table :responsibles do |t|
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :rg
      t.date :birth_date, null: false
      t.string :gender, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
