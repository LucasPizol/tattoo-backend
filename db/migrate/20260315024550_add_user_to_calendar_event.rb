class AddUserToCalendarEvent < ActiveRecord::Migration[8.1]
  def change
    add_reference :calendar_events, :user, foreign_key: true, null: true
  end
end
