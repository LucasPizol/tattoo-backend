class Webhook::Processor < ApplicationJob
  sidekiq_options queue: :default

  HANDLERS = {
    "whatsapp" => {
      "messages" => Webhook::Whatsapp::Messages
    }
  }.freeze

  def perform(webhook_event_id)
    webhook_event = WebhookEvent.find(webhook_event_id)

    handler_class = HANDLERS.dig(webhook_event.provider, webhook_event.event_type)
    raise ArgumentError, "Unknown webhook: #{webhook_event.provider}/#{webhook_event.event_type}" unless handler_class

    handler_class.new(webhook_event).process

    webhook_event.update!(status: :completed)
  rescue => e
    webhook_event.update!(status: :failed, error_message: e.message)
    raise e
  end
end
