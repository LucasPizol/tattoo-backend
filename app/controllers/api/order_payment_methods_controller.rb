class Api::OrderPaymentMethodsController < Api::ApplicationController
  before_action :set_order
  before_action :set_order_payment_method, only: %i[ update destroy ]

  def create
    order_payment_method = @order.order_payment_methods.build(order_payment_method_params)

    if order_payment_method.save
      @order.reload
      head :created
    else
      render_error(order_payment_method)
    end
  end

  def update
    if @order_payment_method.update(order_payment_method_params)
      @order.reload

      head :ok
    else
      render_error(@order_payment_method)
    end
  end

  def destroy
    @order_payment_method.destroy!

    head :no_content
  end

  private

  def order_payment_method_params
    params.expect(order_payment_method: [ :payment_method_id, :value ])
  end

  def set_order
    @order = @current_company.orders.find(params.expect(:order_id))
  end

  def set_order_payment_method
    @order_payment_method = @order.order_payment_methods.find(params.expect(:id))
  end
end
