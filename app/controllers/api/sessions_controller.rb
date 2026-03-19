class Api::SessionsController < Api::ApplicationController
  skip_before_action :authenticate_request, only: %i[ create refresh show ]
  before_action :safe_authenticate_request, only: %i[ refresh show ]

  def show
    if @current_user.present?
      @user = @current_user

      return render :show
    end

    return render json: { message: "Não autorizado" }, status: :unauthorized if refresh_token.blank?

    @user = User.find_by_refresh_token(refresh_token)

    return render json: { message: "Não autorizado" }, status: :unauthorized if @user.blank?

    @user.generate_refresh_token

    set_cookie(@user.id, refresh_token: @user.refresh_token, refresh_token_expires_at: @user.refresh_token_expires_at)

    render :show
  rescue StandardError => e
    render json: { message: "Não autorizado", log_debug: e.message, backtrace: e.backtrace }, status: :unauthorized
  end

  def create
    @user = find_user

    unless @user&.authenticate(authenticate_params[:password])
      return render json: { message: "Não autorizado" }, status: :unauthorized
    end

    @user.generate_refresh_token

    set_cookie(@user.id, refresh_token: @user.refresh_token, refresh_token_expires_at: @user.refresh_token_expires_at)

    render :show
  rescue StandardError => e
    render json: { message: "Não autorizado" }, status: :unauthorized
  end

  def destroy
    clear_user_session
    head :no_content
  end

  def refresh
    return head :no_content if @current_user.present?

    @user = User.find_by_refresh_token(refresh_token)

    return render json: { message: "Token expirado" }, status: :unauthorized if @user.blank?

    @user.generate_refresh_token

    set_cookie(@user.id, refresh_token: @user.refresh_token, refresh_token_expires_at: @user.refresh_token_expires_at)

    head :no_content
  rescue StandardError => e
    render json: { message: "Não autorizado" }, status: :unauthorized
  end

  private

  def authenticate_params
    params.require(:session).permit(:email, :username, :password)
  end

  def find_user
    if authenticate_params[:email].present?
      User.find_by(email: authenticate_params[:email])
    else
      puts "username: #{authenticate_params[:username]}"
      puts "phone: #{PhoneService.normalize(authenticate_params[:username])}"

      User.find_by(username: authenticate_params[:username]) ||
        User.find_by(username: PhoneService.normalize(authenticate_params[:username]))
    end
  end
end
