class Api::ApplicationController < ActionController::API
  include ActionController::Cookies
  include ClassLogger
  include Pundit::Authorization

  before_action :authenticate_request

  private

  def authenticate_request
    decoded = JwtService.decode(token).first
    load_data(decoded["user_id"])
  rescue StandardError => e
    render json: { message: "Não autorizado" }, status: :unauthorized
  end

  def safe_authenticate_request
    decoded = JwtService.decode(token).first
    return if decoded.blank?
    load_data(decoded["user_id"])
  rescue StandardError
    nil
  end

  def load_data(user_id)
    @current_user = cache_user_session(user_id)
    @current_company = cache_company_session
    @current_company_config = cache_company_config
  end

  def current_user
    @current_user
  end

  def pundit_user
    current_user
  end

  def current_company
    @current_company
  end

  def current_company_config
    @current_company_config
  end

  def token
    cookies.encrypted[:jwt]
  end

  def refresh_token
    cookies.encrypted[:refresh_token]
  end

  def session_timeout
    @session_timeout ||= 24.hours
  end

  def cache_user_session(user_id)
    Rails.cache.fetch([ "user_session", user_id ], expires_in: 3.minutes) { User.find(user_id) }
  end

  def cache_company_session
    Rails.cache.fetch([ "company_session", @current_user.id ], expires_in: 3.minutes) { @current_user.company }
  end

  def cache_company_config
    Rails.cache.fetch([ "company_config", @current_company.id ], expires_in: 3.minutes) { @current_company.company_config }
  end

  def clear_user_session_cache
    Rails.cache.delete([ "user_session", @current_company.id ])
  end

  def clear_company_session_cache
    Rails.cache.delete([ "company_session", @current_company.id ])
  end

  def clear_company_config_cache
    Rails.cache.delete([ "company_config", @current_company.id ])
  end

  def clear_user_session
    clear_user_session_cache
    clear_company_session_cache
    clear_company_config_cache
    cookies.delete(:jwt)
  end

  def set_cookie(user_id, refresh_token: nil, refresh_token_expires_at: nil)
    if refresh_token.present? && refresh_token_expires_at.present?
      cookies.encrypted[:refresh_token] = {
        value: refresh_token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :strict,
        expires: refresh_token_expires_at
      }
    end

    cookies.encrypted[:jwt] = {
      value: JwtService.encode(session_timeout, user_id: user_id),
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict,
      expires: session_timeout.from_now
    }
  end

  rescue_from StandardError do |e|
    render json: { message: "Erro interno do servidor", log_debug: e.message, backtrace: e.backtrace }, status: :internal_server_error
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    render json: { message: "Usuário sem privilégios para acessar este recurso" }, status: :forbidden
  end

  rescue_from User::UnauthorizedException do |e|
    render json: { message: e.message }, status: :forbidden
  end

  def render_error(*records)
    compacted_errors = records.compact.flat_map { |record| record&.errors&.as_json(full_messages: true) }
    render json: { errors: compacted_errors.first }, status: :unprocessable_entity
  end
end
