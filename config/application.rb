require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tattoo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.i18n.default_locale = "pt-BR"
    config.i18n.available_locales = [ :"pt-BR", :en ]
    config.i18n.fallbacks = true
    config.i18n.enforce_available_locales = true
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = "Brasilia"
    config.active_record.default_timezone = :utc

    config.active_record.encryption.primary_key =
      ENV.fetch("AR_PRIMARY_KEY", nil)
    config.active_record.encryption.deterministic_key =
      ENV.fetch("AR_DETERMINISTIC_KEY", nil)
    config.active_record.encryption.key_derivation_salt =
      ENV.fetch("AR_KEY_DERIVATION_SALT", nil)
  end
end
