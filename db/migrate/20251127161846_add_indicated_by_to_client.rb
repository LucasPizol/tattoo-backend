class AddIndicatedByToClient < ActiveRecord::Migration[8.1]
  def change
    change_table :clients, bulk: true do |t|
      t.references :indicated_by, foreign_key: { to_table: :clients }, null: true
      t.datetime :indicated_at
    end
  end
end
