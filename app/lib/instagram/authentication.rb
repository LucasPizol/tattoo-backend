# frozen_string_literal: true

module Instagram::Authentication
  def me(access_token)
    response = http_client(token: access_token).get(
      "#{graph_url}/me?fields=id,username,profile_picture_url"
    )

    if response.success?
      {
        id: response.body["id"],
        username: response.body["username"],
        profile_picture_url: response.body["profile_picture_url"]
      }
    else
      raise "Failed to authenticate: #{response.body}"
    end
  end

  def create_short_token(code)
    response = form_http_client(token: nil).post("#{oauth_url}/access_token", {
      client_id: app_id.to_i,
      grant_type: "authorization_code",
      redirect_uri: redirect_uri,
      client_secret: app_secret,
      code: code
    })

    if response.success?
      {
        token: response.body["access_token"],
        expires_at: Time.current + response.body["expires_in"].to_i
      }
    else
      raise "Failed to create short token: #{response.body}"
    end
  end

  def create_long_token(short_access_token)
    response = http_client(token: nil).get(
      "#{graph_url}/access_token?grant_type=ig_exchange_token&client_secret=#{app_secret}&access_token=#{short_access_token}"
    )

    if response.success?
      {
        token: response.body["access_token"],
        expires_at: Time.current + response.body["expires_in"].to_i
      }
    else
      raise "Failed to create long token: #{response.body}"
    end
  end

  def refresh_access_token(access_token)
    response = form_http_client(token: nil).post("#{graph_url}/access_token", {
      grant_type: "ig_refresh_token",
      access_token: access_token
    })

    if response.success?
      {
        token: response.body["access_token"],
        expires_at: Time.current + response.body["expires_in"].to_i
      }
    else
      raise "Failed to refresh token: #{response.body}"
    end
  end
end
