module ClassLogger
  extend ActiveSupport::Concern

  included do
    def log_warn(message)
      Rails.logger.warn("[#{self.class.name}] #{message}")
    end

    def log_error(message)
      Rails.logger.error("[#{self.class.name}] #{message}")
    end

    def log_info(message)
      Rails.logger.info("[#{self.class.name}] #{message}")
    end

    def self.log_info(message)
      Rails.logger.info("[#{self.class.name}] #{message}")
    end

    def self.log_error(message)
      Rails.logger.error("[#{self.class.name}] #{message}")
    end

    def self.log_warn(message)
      Rails.logger.warn("[#{self.class.name}] #{message}")
    end
  end
end
