# == Schema Information
#
# Table name: sale_messages
#
#  id           :bigint           not null, primary key
#  scheduled_at :datetime
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  client_id    :integer          not null
#  order_id     :integer          not null
#
# Indexes
#
#  index_sale_messages_on_client_id  (client_id)
#  index_sale_messages_on_order_id   (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (order_id => orders.id)
#
class SaleMessage < ApplicationRecord
  belongs_to :order
  belongs_to :client

  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :scheduled_at, presence: true
  validates :status, presence: true

  scope :to_send, -> { joins(:order).where(orders: { status: :paid }).where(status: :pending).where("scheduled_at >= ? AND scheduled_at <= ?", Time.current.beginning_of_day, Time.current.end_of_day) }

  def send_message!(perform_in)
    Whatsapp::SendMessageJob.perform_in(perform_in, order.company_id, client.phone, nil, default_message)
    sent!
  end

  def default_message
    passed_days = (Time.current.to_date - order.created_at.to_date).to_i

    "Olá #{client.name.split(' ').first}! 👋
Você realizou uma compra no dia #{order.created_at.strftime('%d/%m/%Y')} e hoje fazem #{passed_days} dias.

Estamos passando para te lembrar de dar uma passadinha aqui para ver como você está. 😊

Muito obrigada pela sua confiança! 💖"
  end
end
