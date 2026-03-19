# == Schema Information
#
# Table name: whatsapp_messages
#
#  id              :bigint           not null, primary key
#  body            :text
#  contact_name    :string
#  direction       :integer          default("inbound"), not null
#  from_number     :string
#  message_type    :integer          default("text"), not null
#  sent_at         :datetime
#  status          :integer          default("pending"), not null
#  template_name   :string
#  to_number       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  company_id      :bigint           not null
#  message_id      :string
#  phone_number_id :string
#
# Indexes
#
#  index_whatsapp_messages_on_company_id                 (company_id)
#  index_whatsapp_messages_on_company_id_and_created_at  (company_id,created_at)
#  index_whatsapp_messages_on_direction                  (direction)
#  index_whatsapp_messages_on_message_id                 (message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class WhatsappMessage < ApplicationRecord
  belongs_to :company

  enum :direction, { inbound: 0, outbound: 1 }
  enum :status, { pending: 0, sent: 1, delivered: 2, read: 3, failed: 4, received: 5 }
  enum :message_type, { text: 0, template: 1, interactive: 2, button: 3 }

  validates :direction, presence: true
  validates :company, presence: true
end
