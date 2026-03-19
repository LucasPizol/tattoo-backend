class SaleMessagesSenderJob < ApplicationJob
  include RandomTimeable

  sidekiq_options queue: :default

  def perform
    SaleMessage.to_send.includes(:order, :client).find_each.with_index do |sale_message, index|
      sale_message.send_message!(random_minutes(index))
    end
  end
end
