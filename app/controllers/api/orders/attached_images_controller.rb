class Api::Orders::AttachedImagesController < Api::ApplicationController
  before_action :set_order

  def index
    @images = @order.images.order(created_at: :desc)
  end

  def create
    @order.images.attach(order_params[:images])
    @order.save!(validate: false)

    head :created
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def destroy
    @order.images.find(params[:id]).purge
    head :no_content
  end

  private

  def set_order
    @order = @current_company.orders.find(params[:order_id])
  end

  def order_params
    params.require(:order).permit(images: [])
  end
end
