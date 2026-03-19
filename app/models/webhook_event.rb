# == Schema Information
#
# Table name: webhook_events
#
#  id              :bigint           not null, primary key
#  error_message   :string
#  event_type      :string           not null
#  idempotency_key :string
#  payload         :jsonb            not null
#  provider        :integer          not null
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_webhook_events_on_event_type       (event_type)
#  index_webhook_events_on_idempotency_key  (idempotency_key) UNIQUE
#  index_webhook_events_on_provider         (provider)
#  index_webhook_events_on_status           (status)
#
class WebhookEvent < ApplicationRecord
  enum :status, { pending: 0, completed: 1, failed: 2 }
  enum :provider, { whatsapp: 0 }

  validates :event_type, presence: true
  validates :payload, presence: true
  validates :status, presence: true
  validates :error_message, presence: true, allow_blank: true

  after_commit :process, on: :create

  def process
    Webhook::Processor.perform_async(id)
  end

  def self.create_and_process(attributes)
    if attributes[:idempotency_key].blank?
      webhook_event = create!(**attributes)
      webhook_event.process
      return webhook_event
    end

    webhook_event = find_by(idempotency_key: attributes[:idempotency_key])

    if webhook_event.present?
      if webhook_event.failed?
        webhook_event.update!(**attributes)
        webhook_event.process
      end
      puts "Webhook event already processed"

      return webhook_event
    end

    webhook_event = create!(**attributes)
    webhook_event.process
  end
end
