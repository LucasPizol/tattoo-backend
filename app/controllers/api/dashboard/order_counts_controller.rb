class Api::Dashboard::OrderCountsController < Api::Dashboard::BaseController
  def index
    render json: { orderCount: order_count }
  end

  private

  def order_count
    order_scope.paid.ransack(search_params).result.count
  end
end
