class Shipping::GenerateTrackingJob < ApplicationJob
  sidekiq_options queue: :default

  def perform(shipping)
    # TODO: Implement tracking number generation using the shipping company API
    return if shipping.tracking_number.present?

    shipping.update!(tracking_number: SecureRandom.hex(10))
  end
end
