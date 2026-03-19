class Whatsapp::Client
  GRAPH_API_BASE = "https://graph.facebook.com/v24.0"

  include Whatsapp::SendMessage
  include Whatsapp::SendTemplate
  include Whatsapp::SendUrl

  def initialize(company)
    @company = company
  end

  def messages_url
    "#{GRAPH_API_BASE}/#{@company.whatsapp_phone_number_id}/messages"
  end

  def http_client
    @http_client ||= Faraday.new do |faraday|
      faraday.headers["Authorization"] = "Bearer #{@company.whatsapp_access_token}"
      faraday.headers["Content-Type"] = "application/json"
    end
  end
end
