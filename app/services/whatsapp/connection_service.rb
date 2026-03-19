class Whatsapp::ConnectionService
  GRAPH_API_BASE = "https://graph.facebook.com/v24.0"
  TOKEN_URL = "https://graph.facebook.com/oauth/access_token"

  def initialize(company:, code:, phone_number_id:, waba_id:)
    @company = company
    @code = code
    @phone_number_id = phone_number_id
    @waba_id = waba_id
  end

  def call
    token = exchange_code_for_token
    @company.update!(
      whatsapp_access_token: token,
      whatsapp_phone_number_id: @phone_number_id,
      whatsapp_waba_id: @waba_id
    )
    @company
  end

  private

  def exchange_code_for_token
    response = Faraday.get(TOKEN_URL, {
      client_id: ENV.fetch("META_APP_ID"),
      client_secret: ENV.fetch("META_APP_SECRET"),
      code: @code
    })

    raise "Failed to exchange WhatsApp OAuth code: #{response.body}" unless response.success?

    parsed = JSON.parse(response.body)
    parsed["access_token"] || raise("No access_token in Meta response")
  end
end
