class CompanyChannel < ApplicationCable::Channel
  include ClassLogger

  def subscribed
    stream_for current_company
  end

  def unsubscribed
    stop_all_streams
  end
end
