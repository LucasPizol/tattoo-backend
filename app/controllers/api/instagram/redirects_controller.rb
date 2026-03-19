class Api::Instagram::RedirectsController < Api::ApplicationController
  def index
    authorized_with_user_token = "#{instagram_authorize_url}&state=#{cookies.encrypted[:jwt]}"

    render json: { url: authorized_with_user_token }
  end

  private

  def instagram_authorize_url
    "https://www.instagram.com/oauth/authorize?force_reauth=true&client_id=#{app_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=instagram_business_basic%2Cinstagram_business_manage_messages%2Cinstagram_business_manage_comments%2Cinstagram_business_content_publish%2Cinstagram_business_manage_insights"
  end

  def app_id
    @app_id ||= ENV.fetch("META_APP_ID")
  end

  def redirect_uri
    @redirect_uri ||= "#{ENV.fetch("FRONTEND_URL")}/instagram/success"
  end
end
