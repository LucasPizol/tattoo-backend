class Webhook::Whatsapp::Messages
  include Webhookable

  def process
    payload = Whatsapp::MessagePayload.from_json(@webhook_event.payload)
    return unless payload

    company = Company.find_by(whatsapp_phone_number_id: payload.phone_number_id)
    return unless company

    if payload.status == "received"
      persist_inbound!(company, payload)
    else
      update_message_status!(payload)
    end
  end

  private

  def persist_inbound!(company, payload)
    company.whatsapp_messages.find_or_create_by(message_id: payload.id) do |msg|
      msg.direction = :inbound
      msg.status = :received
      msg.message_type = :text
      msg.from_number = payload.from
      msg.to_number = payload.to
      msg.phone_number_id = payload.phone_number_id
      msg.body = payload.body
      msg.contact_name = payload.contact_name
      msg.sent_at = payload.sent_at
    end
  rescue => e
    Rails.logger.error("Failed to persist inbound WhatsApp message: #{e.message}")
  end

  def update_message_status!(payload)
    message = WhatsappMessage.find_by(message_id: payload.id)
    return unless message

    status = payload.status.to_sym
    message.update(status: status) if WhatsappMessage.statuses.key?(status.to_s)
  rescue => e
    Rails.logger.error("Failed to update WhatsApp message status: #{e.message}")
  end
end
