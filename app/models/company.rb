# == Schema Information
#
# Table name: companies
#
#  id                       :bigint           not null, primary key
#  cnpj                     :string
#  name                     :string           not null
#  whatsapp_access_token    :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  whatsapp_phone_number_id :string
#  whatsapp_waba_id         :string
#
# Indexes
#
#  index_companies_on_cnpj                      (cnpj) UNIQUE
#  index_companies_on_whatsapp_phone_number_id  (whatsapp_phone_number_id) UNIQUE
#
class Company < ApplicationRecord
  MAIN_COMPANY_ID = 1

  encrypts :whatsapp_access_token

  has_many :users, dependent: :destroy, inverse_of: :company
  has_many :clients, dependent: :destroy, inverse_of: :company
  has_many :addresses, through: :clients, dependent: :destroy
  has_many :tags, dependent: :destroy, inverse_of: :company
  has_many :materials, dependent: :destroy, inverse_of: :company
  has_many :products, dependent: :destroy, inverse_of: :company
  has_many :stocks, dependent: :destroy, through: :products
  has_many :stock_movements, through: :stocks, dependent: :destroy
  has_many :payment_methods, dependent: :destroy, inverse_of: :company
  has_many :orders, dependent: :destroy, inverse_of: :company
  has_many :order_products, dependent: :destroy, inverse_of: :company
  has_many :responsibles, dependent: :destroy, inverse_of: :company
  has_many :images_attachments, through: :products, dependent: :destroy, inverse_of: :company
  has_many :calendar_events, dependent: :destroy, inverse_of: :company
  has_many :notes, dependent: :destroy, inverse_of: :company
  has_many :reports, dependent: :destroy, inverse_of: :company
  has_one :company_config, dependent: :destroy, inverse_of: :company
  has_many :campaigns, dependent: :destroy, inverse_of: :company
  has_many :company_instagram_accounts, -> { where(company_account: true) }, class_name: "Instagram::Account", dependent: :destroy, inverse_of: :company
  has_many :clients_instagram_accounts, -> { where(company_account: false) }, class_name: "Instagram::Account", dependent: :destroy, inverse_of: :company
  has_many :instagram_posts, through: :company_instagram_accounts, dependent: :destroy, source: :posts
  has_many :payments, through: :orders, dependent: :destroy
  has_many :raffles, dependent: :destroy, inverse_of: :company
  has_many :roles, dependent: :destroy, inverse_of: :company
  has_many :user_invites, dependent: :destroy, inverse_of: :company
  has_many :whatsapp_messages, dependent: :destroy

  def whatsapp_connected?
    whatsapp_access_token.present? && whatsapp_phone_number_id.present?
  end
end
