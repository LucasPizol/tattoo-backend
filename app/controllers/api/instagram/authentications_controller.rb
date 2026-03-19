class Api::Instagram::AuthenticationsController < Api::ApplicationController
  def index
    Instagram::AuthenticationService.call(code: code, user: @current_user)

    head :ok
  rescue StandardError => e
    log_error("Error authenticating instagram: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def code
    params.expect(:code).split("#").first
  end
end
