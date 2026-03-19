class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.string :status, null: false, default: "open"
      t.string :priority, null: false, default: "low"
      t.datetime :due_date
      t.datetime :completed_at

      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index :status
      t.index :priority
      t.index :due_date
      t.index :completed_at
    end
  end
end
