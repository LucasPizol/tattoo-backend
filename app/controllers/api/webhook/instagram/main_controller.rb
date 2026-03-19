class Api::Webhook::Instagram::MainController < Api::ApplicationController
  skip_before_action :authenticate_request

  def index
    if params["hub.verify_token"] != ENV.fetch("INSTAGRAM_VERIFY_CALLBACK_HASH")
      return render json: { message: "Invalid verify token" }, status: :unauthorized
    end

    render json: params["hub.challenge"], status: :ok
  end

  def create
    Log.create(api_type: "instagram", method: "create", request_body: params.to_json, response_body: nil, status: "success", direction: "in", where: self.class.name)

    case webhook_type
    when "comments"
      handler.new(value).create_comment
    else
      Log.create(
        api_type: "instagram",
        method: "create",
        request_body: params.to_json,
        response_body: nil,
        status: "error",
        direction: "in",
        where: self.class.name,
        message: "Webhook type not supported"
      )
      render json: { message: "Webhook type not supported" }, status: :unprocessable_entity
    end
  end

  def handler
    "Api::Webhook::Instagram::Handlers::#{webhook_type.capitalize}".constantize
  end

  def changes
    params[:entry].first[:changes].first
  end

  def webhook_type
    changes[:field]
  end

  def value
    changes[:value]
  end
end
