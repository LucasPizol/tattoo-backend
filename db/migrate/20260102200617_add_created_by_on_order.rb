class AddCreatedByOnOrder < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :created_by, :integer, default: 0
    add_column :orders, :idempotency_key, :string, null: true
    add_column :orders, :external_id, :integer, null: true
  end
end
