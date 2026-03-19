class JwtService
  def self.encode(expires_in = 15.minutes, payload)
    JWT.encode(payload, secret_key, "HS256", { exp: expires_in.from_now.to_i })
  end

  def self.decode(token)
    JWT.decode(token, secret_key)
  end

  private

  def self.secret_key
    ENV.fetch("JWT_SECRET_KEY", "secret")
  end
end
