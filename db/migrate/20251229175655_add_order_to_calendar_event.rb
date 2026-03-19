class AddOrderToCalendarEvent < ActiveRecord::Migration[8.1]
  def change
    add_reference :calendar_events, :order, foreign_key: true
  end
end
