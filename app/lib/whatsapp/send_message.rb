module Whatsapp::SendMessage
  def send_message(phone, message, enable_link_preview: false)
    body = {
      messaging_product: "whatsapp",
      to: phone,
      type: "text",
      text: {
        body: message
      }
    }.to_json

    if Rails.env.development?
      Rails.logger.info("Whatsapp message: #{body}")
      return true
    end

    response = http_client.post(messages_url, body)

    if response.success?
      true
    else
      Rails.logger.error("Whatsapp message failed to send to #{phone}: #{response.body}")
      false
    end
  end
end
