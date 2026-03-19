class Api::Webhook::Correios::ShipmentsController < Api::ApplicationController
  skip_before_action :authenticate_request

  def create
    shipping = Shipping.find_by!(tracking_number: webhook_params[:tracking_number])

    shipping.update!(status: webhook_params[:status])

    shipping.order.adjust_shipping_value if shipping.in_progress?

    render json: { message: "Shipment updated" }
  end

  private

  def webhook_params
    params.expect(shipment: [ :event, :tracking_number, :status ])
  end
end
