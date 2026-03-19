class UpdatesColumnsWithUser < ActiveRecord::Migration[8.1]
  def change
    rename_column :clients, :user_id, :company_id
    rename_column :categories, :user_id, :company_id
    rename_column :materials, :user_id, :company_id
    rename_column :products, :user_id, :company_id
    rename_column :payment_methods, :user_id, :company_id
    rename_column :orders, :user_id, :company_id
    rename_column :stock_movements, :user_id, :company_id
    rename_column :calendar_events, :user_id, :company_id
    rename_column :notes, :user_id, :company_id
    rename_column :reports, :user_id, :company_id
    rename_column :company_configs, :user_id, :company_id
  end
end
