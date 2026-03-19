class ApplicationController < ActionController::Base
  before_action :authenticate_request

  private

  def authenticate_request
    decoded = JwtService.decode(token).first

    @current_user = Rails.cache.fetch([ "user_session", decoded["user_id"] ], expires_in: 3.minutes) do
      User.find(decoded["user_id"])
    end

    @current_company = Rails.cache.fetch([ "company_session", @current_user.company_id ], expires_in: 3.minutes) do
      @current_user.company
    end
  rescue StandardError
    redirect_to new_session_path
  end

  def token
    cookies.encrypted[:jwt]
  end
end
