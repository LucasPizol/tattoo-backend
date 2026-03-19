module Whatsapp::SendUrl
  def send_url(phone:, message:, url:, display_text:, header: nil, footer: nil, enable_link_preview: false)
    body = {
      messaging_product: "whatsapp",
      to: phone,
      type: "interactive",
      interactive: {
        type: "cta_url",
        body: {
          text: message
        },
        action: {
          name: "cta_url",
          parameters: {
            url: url,
            display_text: display_text
          }
        }
      }.tap do |b|
        b[:header] = { type: "text", text: header } if header.present?
        b[:footer] = { text: footer } if footer.present?
      end
    }.to_json

    response = http_client.post(messages_url, body)

    if response.success?
      true
    else
      Rails.logger.error("Whatsapp message failed to send to #{phone}: #{response.body}")
      false
    end
  end
end
