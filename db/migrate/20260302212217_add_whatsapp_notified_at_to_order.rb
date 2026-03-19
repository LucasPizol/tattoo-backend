class AddWhatsappNotifiedAtToOrder < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :whatsapp_notified_at, :datetime
  end
end
