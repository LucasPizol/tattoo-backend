class AddWhatsappOauthToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :whatsapp_access_token, :text
    add_column :companies, :whatsapp_phone_number_id, :string
    add_column :companies, :whatsapp_waba_id, :string

    add_index :companies, :whatsapp_phone_number_id, unique: true
  end
end
