class CreateWebhookEvent < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.string :event_type, null: false
      t.jsonb :payload, null: false
      t.integer :status, null: false, default: 0
      t.string :error_message
      t.integer :provider, null: false
      t.string :idempotency_key

      t.timestamps

      t.index :event_type
      t.index :status
      t.index :provider
      t.index :idempotency_key, unique: true
    end
  end
end
