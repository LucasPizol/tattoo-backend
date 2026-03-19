class Facebook::Base
  def call
    raise NotImplementedError, "Subclasses must implement the call method"
  end

  private

  def send_request(url, body, headers: {}, method: "post")
    response = HTTParty.send(method.to_sym, url,
                             body: headers["Content-Type"] == "application/x-www-form-urlencoded" ? body : body&.to_json,
                             headers: {
                              "Content-Type" => "application/json",
                              "Authorization" => "Bearer #{access_token}"
                            }.merge(headers))

    response
  end

  def base_url
    @base_url ||= "https://graph.facebook.com/v24.0"
  end

  def account_id
    @account_id ||= ENV.fetch("INSTAGRAM_ACCOUNT_ID")
  end

  def app_secret
    @app_secret ||= ENV.fetch("INSTAGRAM_APP_SECRET")
  end

  def app_id
    @app_id ||= ENV.fetch("INSTAGRAM_APP_ID")
  end

  def access_token
    @access_token ||= ENV.fetch("INSTAGRAM_ACCOUNT_ACCESS_TOKEN")
  end
end
