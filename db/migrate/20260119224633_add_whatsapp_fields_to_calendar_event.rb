class AddWhatsappFieldsToCalendarEvent < ActiveRecord::Migration[8.1]
  def change
    change_table :calendar_events, bulk: true do |t|
      t.string :whatsapp_message
      t.boolean :send_whatsapp_message, null: false, default: false
      t.string :phone
      t.string :client_name
      t.datetime :sent_whatsapp_message_at
    end
  end
end
