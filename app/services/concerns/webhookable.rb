module Webhookable
  extend ActiveSupport::Concern

  included do
    include ClassLogger

    def initialize(webhook_event)
      @webhook_event = webhook_event
    end

    def process
      raise NotImplementedError, "Subclasses must implement the process method"
    end
  end
end
