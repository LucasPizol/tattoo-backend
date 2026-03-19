module Whatsapp::SendTemplate
  def send_template(phone, template_name, components = nil, language = "pt_BR")
    button_components = components&.select { |component| component.is_a?(Whatsapp::Components::ButtonComponent) }
    text_components = components&.select { |component| component.is_a?(Whatsapp::Components::TextComponent) }

    button_components = button_components.map.with_index do |component, index|
      param = component.to_h
      next if param.blank?

      {
        type: "button",
        sub_type: component.sub_type,
        index: index.to_s,
        parameters: [ param ]
      }
    end.compact if button_components.present?

    text_components = {
      type: "body",
      parameters: text_components.map { |component| component.to_h }
    } if text_components.present?

    body = {
      messaging_product: "whatsapp",
      to: phone,
      type: "template",
      template: {
        name: template_name,
        language: { code: language },
        components: [ button_components, text_components ].compact_blank.flatten
      }
    }.to_json

    if Rails.env.development?
      Rails.logger.info("Whatsapp template: #{body}")
      return true
    end

    response = http_client.post(messages_url, body)

    if response.success?
      true
    else
      Rails.logger.error("Whatsapp template failed to send to #{phone}: #{response.body}")
      false
    end
  end
end
