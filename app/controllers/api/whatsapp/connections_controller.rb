class Api::Whatsapp::ConnectionsController < Api::ApplicationController
  def show
    render json: {
      connected: @current_user.company.whatsapp_connected?,
      phone_number_id: @current_user.company.whatsapp_phone_number_id,
      waba_id: @current_user.company.whatsapp_waba_id
    }
  end

  def create
    Whatsapp::ConnectionService.new(
      company: @current_user.company,
      code: params.expect(:code),
      phone_number_id: params.expect(:phone_number_id),
      waba_id: params.expect(:waba_id)
    ).call

    render json: { connected: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @current_user.company.update!(
      whatsapp_access_token: nil,
      whatsapp_phone_number_id: nil,
      whatsapp_waba_id: nil
    )

    head :no_content
  end
end
