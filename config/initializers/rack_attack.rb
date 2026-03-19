Rack::Attack.cache.store = Rails.cache

logger = ActiveSupport::Logger.new(Rails.root.join("log", "#{Rails.env}_rack_attack.log"))

Rack::Attack.safelist("allow-localhost") do |req|
  req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
end

Rack::Attack.safelist("allow-health-check") do |req|
  req.path == "/up"
end

Rack::Attack.safelist("allow-webhooks") do |req|
  req.path.start_with?("/api/webhook/")
end

Rack::Attack.blocklist("block-abusive-ips") do |req|
  Rack::Attack.cache.read("#{req.ip}:blocked").present?
end

Rack::Attack.throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
  if req.path.start_with?("/api/sessions") && req.post? && !req.path.start_with?("/cable")
    req.ip
  end
end

Rack::Attack.throttle("req/ip", limit: 300, period: 5.minutes) do |req|
  if !req.path.start_with?("/api/webhook/") && !req.path.start_with?("/cable")
    req.ip
  end
end

Rack::Attack.throttle("req/ip/minute", limit: 100, period: 30.seconds) do |req|
  if !req.path.start_with?("/api/webhook/") && !req.path.start_with?("/cable")
    req.ip
  end
end

# Throttle para requisições de criação (POST) - mais restritivo
Rack::Attack.throttle("req/ip/post", limit: 30, period: 5.minutes) do |req|
  if req.post? && !req.path.start_with?("/api/webhook/") && !req.path.start_with?("/cable")
    req.ip
  end
end

Rack::Attack.throttle("req/ip/modify", limit: 50, period: 5.minutes) do |req|
  if (req.put? || req.patch? || req.delete?) && !req.path.start_with?("/api/webhook/") && !req.path.start_with?("/cable")&& !req.path.start_with?("/cable")
    req.ip
  end
end

Rack::Attack.track("abusive-ips", limit: 100, period: 30.seconds) do |req|
  if !req.path.start_with?("/api/webhook/") && !req.path.start_with?("/cable")
    req.ip
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]

  case req.env["rack.attack.match_type"]
  when :blocklist
    logger.warn "[Rack::Attack] IP bloqueado: #{req.ip} - #{req.path}"
  when :throttle
    matched = req.env["rack.attack.matched"]
    logger.warn "[Rack::Attack] Throttle ativado: #{matched} - IP: #{req.ip} - #{req.path}"

    throttle_key = "throttle_count:#{req.ip}"
    throttle_count = Rack::Attack.cache.read(throttle_key).to_i + 1

    if throttle_count > 10
      Rack::Attack.cache.write("#{req.ip}:blocked", true, 1.hour)
      logger.error "[Rack::Attack] IP adicionado à lista de bloqueio após #{throttle_count} throttles: #{req.ip}"
    end
  when :track
    matched = req.env["rack.attack.matched"]
    if matched == "abusive-ips"
      Rack::Attack.cache.write("#{req.ip}:blocked", true, 1.hour)
      logger.error "[Rack::Attack] IP adicionado à lista de bloqueio por comportamento abusivo: #{req.ip}"
    end
  end
end
