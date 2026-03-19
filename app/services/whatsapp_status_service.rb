class WhatsappStatusService
  include ClassLogger

  def initialize(user_id)
    @user_id = user_id
  end

  def reconnect_whatsapp
    response = HTTParty.post("#{base_url}/reconnect/#{@user_id}", headers: common_headers)

    log_response(response)
  end

  def disconnect_whatsapp
    response = HTTParty.delete("#{base_url}/disconnect/#{@user_id}", headers: common_headers)

    log_response(response)
  end

  def build_response(json = nil)
    @response ||= json if json.present?

    if json.present?
      log_info("BUILD RESPONSE: #{json}")
    end

    hash = {
      connected: connected?,
      authenticated: authenticated?,
      initialized: initialized?,
      initializing: initializing?,
      memory_used: memory_used,
      memory_total: memory_total,
      uptime: uptime,
      qr_code: connected? ? nil : qr_code,
      error_message: error_message,
      whatsapp_opened: whatsapp_opened?,
      connecting: connecting?
    }

    hash
  end

  def connected?
    request.dig(:whatsapp, :connected).presence || false
  end

  def whatsapp_opened?
    request.dig(:whatsapp_opened).presence || false
  end

  def connecting?
    request.dig(:whatsapp, :connecting).presence || false
  end

  def authenticated?
    request.dig(:whatsapp, :authenticated).presence || false
  end

  def initialized?
    request.dig(:whatsapp, :initialized).presence || false
  end

  def initializing?
    request.dig(:whatsapp, :initializing).presence || false
  end

  def qr_code
    request.dig(:whatsapp, :qr_code).presence || nil
  end

  def error_message
    request.dig(:whatsapp, :error_message).presence || false
  end

  def memory_used
    request.dig(:memory, :used).presence || false
  end

  def memory_total
    request.dig(:memory, :total).presence || false
  end

  def uptime
    request[:uptime].presence || false
  end

  def whatsapp_opened?
    request.dig(:whatsapp_opened).presence || false
  end

  def request
    @request ||= begin
      response = HTTParty.get("#{base_url}/health/#{@user_id}", headers: common_headers)

      if response.success?
        JSON.parse(response.body, symbolize_names: true)
      else
        {
          connected: false,
          authenticated: false,
          initialized: false,
          initializing: false
        }
      end
    end
  end

  def base_url
    "http://#{ENV.fetch("HOST", "localhost:3002")}"
  end

  def log_response(response)
    if response.success?
      log_info("WhatsApp client success: #{response}")
    else
      log_error("WhatsApp client failed: #{response}")
    end
  end

  def common_headers
    { "Content-Type" => "application/json", "X-Client-Secret" => ENV.fetch("CLIENT_SECRET") }
  end
end
