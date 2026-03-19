class Api::Webhook::Whatsapp::HandlersController < Api::ApplicationController
  skip_before_action :authenticate_request

  WEBHOOK_EVENTS = %w[messages]

  def index
    if params["hub.verify_token"] != ENV.fetch("WHATSAPP_WEBHOOK_VERIFY_TOKEN")
      return render json: { message: "Invalid verify token" }, status: :unauthorized
    end

    render json: params["hub.challenge"], status: :ok
  end

  def create
    if !WEBHOOK_EVENTS.include?(webhook_type)
      return render json: { message: "Webhook type not supported" }, status: :unprocessable_entity
    end

    WebhookEvent.create_and_process(
      event_type: webhook_type,
      payload: params,
      status: :pending,
      provider: :whatsapp,
      idempotency_key: Whatsapp::MessagePayload.idempotency_key(JSON.parse(params.to_json, symbolize_names: true))
    )

    render json: { message: "Webhook event created" }, status: :ok
  end

  private

  def webhook_type
    params[:entry].first[:changes].first[:field]
  end
end
