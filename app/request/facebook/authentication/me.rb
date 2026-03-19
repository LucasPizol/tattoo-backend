class Facebook::Authentication::Me < Facebook::Base
  def self.call(access_token:)
    new(access_token: access_token).call
  end

  def initialize(access_token:)
    @access_token = access_token
  end

  def call
    response = send_request(
      "#{base_url}/me?fields=id,name,instagram_business_account",
      nil,
      method: "get",
      headers: { "Authorization" => "Bearer #{@access_token}" }
    )

    if response.success?
      {
        id: response["id"],
        username: response["username"],
        profile_picture_url: response["profile_picture_url"]
      }
    else
      raise "Failed to authenticate: #{response.body}"
    end
  end

  def base_url
    @base_url ||= "https://graph.instagram.com"
  end
end
