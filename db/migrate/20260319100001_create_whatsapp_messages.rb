class CreateWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_messages do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :direction, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :message_type, null: false, default: 0
      t.string :message_id
      t.string :from_number
      t.string :to_number
      t.string :phone_number_id
      t.text :body
      t.string :contact_name
      t.string :template_name
      t.datetime :sent_at

      t.timestamps
    end

    add_index :whatsapp_messages, :message_id, unique: true
    add_index :whatsapp_messages, [ :company_id, :created_at ]
    add_index :whatsapp_messages, :direction
  end
end
