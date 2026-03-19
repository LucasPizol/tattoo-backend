class Api::OrderProductsController < Api::ApplicationController
  before_action :set_order, only: %i[ create ]
  before_action :set_order_product, only: %i[ update destroy ]

  def create
    @order_product = @order.order_products.build(order_product_params)

    if @order_product.save
      render :show, status: :created
    else
      render_error(@order_product)
    end
  end

  def update
    if @order_product.update(order_product_params)
      render :show, status: :ok
    else
      render_error(@order_product)
    end
  end

  def destroy
    @order_product.destroy!

    head :no_content
  end

  def bulk_insert
    order_id = bulk_order_product_params.first.expect(:order_id)

    if order_id.blank? || bulk_order_product_params.any? { it[:order_id] != order_id }
      return render_error("All order products must be for the same order")
    end

    order = @current_company.orders.find(order_id)

    data = bulk_order_product_params.map do |order_product|
      {
        order_id: order_id,
        stock_id: order_product.expect(:stock_id),
        quantity: order_product.expect(:quantity),
        value_subcents: order_product.expect(:value)
      }
    end

    ActiveRecord::Base.transaction do
      OrderProduct.insert_all(data)
      order.reload.recalculate_values
      order.calculate_comissions
      order.save
    end

    head :created
  end

  private
    def set_order
      @order = @current_company.orders.find(order_product_params.expect(:order_id))
    end

    def set_order_product
      @order_product = OrderProduct.find(params.expect(:id))
    end

    def order_product_params
      params.expect(order_product: [ :order_id, :stock_id, :quantity, :value ])
    end

    def bulk_order_product_params
      params.expect(order_products: [ [ :order_id, :stock_id, :quantity, :value ] ])
    end
end
