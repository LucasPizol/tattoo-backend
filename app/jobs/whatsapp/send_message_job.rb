class Whatsapp::SendMessageJob < ApplicationJob
  sidekiq_options queue: :default

  def perform(company_id, phone, template = nil, message = nil)
    return if phone.nil?

    company = Company.find(company_id)
    return unless company.whatsapp_connected?

    phone = phone.starts_with?("55") ? phone : "55#{phone}"

    if template.present?
      template = template.is_a?(String) ? JSON.parse(template) : template
      template_name = template["template_name"]

      Whatsapp::Client.new(company).send_template(
        phone,
        template_name,
        template["components"],
        template["language"] || "pt_BR"
      )

      persist_outbound!(company, phone, message_type: :template, template_name: template_name)
    else
      Whatsapp::Client.new(company).send_message(phone, message)

      persist_outbound!(company, phone, message_type: :text, body: message)
    end
  end

  private

  def persist_outbound!(company, phone, message_type:, body: nil, template_name: nil)
    company.whatsapp_messages.create!(
      direction: :outbound,
      status: :sent,
      message_type: message_type,
      to_number: phone,
      from_number: company.whatsapp_phone_number_id,
      phone_number_id: company.whatsapp_phone_number_id,
      body: body,
      template_name: template_name,
      sent_at: Time.current
    )
  rescue => e
    Rails.logger.error("Failed to persist outbound WhatsApp message: #{e.message}")
  end
end
