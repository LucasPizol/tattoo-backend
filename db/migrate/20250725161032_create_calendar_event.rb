class CreateCalendarEvent < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.string :title, null: false
      t.string :event_type, null: false
      t.text :description
      t.references :user, foreign_key: true, null: false
      t.references :client, foreign_key: true
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :status, null: false, default: "pending"
      t.integer :reschedule_count, null: false, default: 0

      t.timestamps
    end
  end
end
