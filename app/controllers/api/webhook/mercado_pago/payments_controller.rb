class Api::Webhook::MercadoPago::PaymentsController < Api::ApplicationController
  skip_before_action :authenticate_request

  def create
    @order = Order.find(mercado_pago_payment["external_reference"])
    @payment = @order.payments.find_or_initialize_by(external_id: mercado_pago_payment["id"], owner: :client)

    transaction_details = mercado_pago_payment["transaction_details"]

    @payment.update!(
      net_received_value: transaction_details["net_received_amount"],
      total_paid_amount: transaction_details["total_paid_amount"],
      installment_amount: transaction_details["installment_amount"],
      external_id: mercado_pago_payment["id"],
      status: payment_status
    )

    return head :ok if @order.paid?

    OrderProcessorJob.perform_async(@order.id)

    render json: { message: "Payment received" }, status: :ok
  rescue => e
    render json: { message: "Error: #{e.message}" }, status: :internal_server_error
  end

  private

  def mercado_pago_payment
    if Rails.env.development?
      return JSON.parse(File.read("test/fixtures/files/mercado_pago/payment_approved.json"))["data"]
    end

    @mercado_pago_payment ||= Checkout::MercadoPagoService.new.get_payment(params["data"]["id"])
  end

  def payment_status
    Checkout::MercadoPagoService::PAYMENT_STATUS_MAP[mercado_pago_payment["status"]]
  end
end
