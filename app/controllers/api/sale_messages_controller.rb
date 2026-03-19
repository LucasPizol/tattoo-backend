class Api::SaleMessagesController < Api::ApplicationController
  before_action :set_order
  before_action :set_sale_message, only: %i[ show update destroy ]

  def index
    authorize(SaleMessage, :index?)

    @sale_messages = @order.sale_messages.order(created_at: :desc).ransack(search_params).result
  end

  def show
    authorize(@sale_message, :show?)
  end

  def create
    authorize(SaleMessage, :create?)

    @sale_message = @order.sale_messages.build(sale_message_params.merge(status: :pending, client: @order.client))

    if @sale_message.save
      render :show, status: :created
    else
      render_error(@sale_message)
    end
  end

  def update
    authorize(@sale_message, :update?)

    if @sale_message.update(sale_message_params)
      render :show, status: :ok
    else
      render_error(@sale_message)
    end
  end

  def destroy
    authorize(@sale_message, :destroy?)

    @sale_message.destroy!

    head :no_content
  end

  private
    def set_sale_message
      @sale_message = @order.sale_messages.find(params.expect(:id))
    end

    def sale_message_params
      params.expect(sale_message: [ :scheduled_at, :order_id ])
    end

    def search_params
      params.fetch(:q, {}).permit(:scheduled_at_gteq, :scheduled_at_lteq)
    end

    def set_order
      @order = @current_company.orders.find(params.expect(:order_id))
    end
end
