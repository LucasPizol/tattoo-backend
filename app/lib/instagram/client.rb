# frozen_string_literal: true

class Instagram::Client
  GRAPH_URL = "https://graph.instagram.com/v24.0"
  OAUTH_URL = "https://api.instagram.com/oauth"

  include Instagram::Authentication
  include Instagram::Media
  include Instagram::Comments

  private

  def graph_url
    GRAPH_URL
  end

  def oauth_url
    OAUTH_URL
  end

  def redirect_uri
    "#{ENV.fetch("FRONTEND_URL")}/instagram/success"
  end

  def http_client(token: access_token)
    Faraday.new do |faraday|
      faraday.headers["Authorization"] = "Bearer #{token}" if token
      faraday.headers["Content-Type"] = "application/json"
      faraday.response :json
    end
  end

  def form_http_client(token: access_token)
    Faraday.new do |faraday|
      faraday.headers["Authorization"] = "Bearer #{token}" if token
      faraday.headers["Content-Type"] = "application/x-www-form-urlencoded"
      faraday.request :url_encoded
      faraday.response :json
    end
  end

  def access_token
    ENV.fetch("INSTAGRAM_ACCOUNT_ACCESS_TOKEN", "")
  end

  def account_id
    ENV.fetch("INSTAGRAM_ACCOUNT_ID")
  end

  def app_secret
    ENV.fetch("INSTAGRAM_APP_SECRET")
  end

  def app_id
    ENV.fetch("INSTAGRAM_APP_ID")
  end
end
