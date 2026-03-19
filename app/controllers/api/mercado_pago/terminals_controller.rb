class Api::MercadoPago::TerminalsController < Api::ApplicationController
  before_action :set_order, only: %i[ create ]

  def index
    @terminals = Checkout::MercadoPagoService.new.list_terminals
  end

  def create
    with_development_environment do
      Checkout::MercadoPagoService.new.create_terminal_order(@order, terminal_id: params.expect(:terminal_id))
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = @current_company.orders.find(params.expect(:order_id))
  end

  def with_development_environment
    if Rails.env.development?
      @order.waiting_for_payment!
      head :created
    else
      yield
    end
  end
end
