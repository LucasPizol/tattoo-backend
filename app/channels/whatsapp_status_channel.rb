class WhatsappStatusChannel < ApplicationCable::Channel
  include ClassLogger

  def subscribed
    stream_for "whatsapp_status_#{current_user.id}"

    data = whatsapp_service.build_response

    transmit(data)
  rescue => e
    log_error("Error building response: #{e.message}")
  end

  def unsubscribed
    stop_all_streams
  end

  def receive(data)
    type = data["type"]

    log_info("Received data: #{data}")

    case type
    when "reconnect_whatsapp"
      whatsapp_service.reconnect_whatsapp
    when "disconnect_whatsapp"
      whatsapp_service.disconnect_whatsapp
    end
  end

  private

  def whatsapp_service
    @whatsapp_service ||= WhatsappStatusService.new(current_user.id)
  end
end
