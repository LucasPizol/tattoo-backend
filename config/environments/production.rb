require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.active_storage.service = :amazon

  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.assume_ssl = true
  config.force_ssl = true

  config.ssl_options = {
    redirect: {
      exclude: ->(request) { request.path == "/up" || request.path.include?("/webhook") }
    }
  }

  config.host_authorization = {
    exclude: ->(request) { request.path == "/up" || request.path.include?("/webhook") }
  }

  config.hosts << "api.tattoo.rainbowpiercing.com.br"
  config.hosts << "tattoo.rainbowpiercing.com.br"
  config.hosts << "api.tattoo.rainbowpiercing.com.br"

  config.active_support.report_deprecations = false

  config.middleware.delete Rails::Rack::Logger

  # Log to STDOUT for Docker/Kamal
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.action_cable.allowed_request_origins = [
    "https://software.rainbowpiercing.com.br",
    "https://api.tattoo.rainbowpiercing.com.br",
    "http://api.tattoo.rainbowpiercing.com.br"
  ]

  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL") }

  config.action_mailer.smtp_settings = {
    user_name: ENV.fetch("SMTP_USER_NAME", ""),
    password: ENV.fetch("SMTP_PASSWORD", ""),
    address: ENV.fetch("SMTP_ADDRESS", ""),
    port: ENV.fetch("SMTP_PORT", ""),
    authentication: :plain
  }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]
end
