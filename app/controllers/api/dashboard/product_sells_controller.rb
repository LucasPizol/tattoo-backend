class Api::Dashboard::ProductSellsController < Api::Dashboard::BaseController
  def index
    render json: { productSells: product_sells }
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def product_sells
    order_scope.paid
               .ransack(search_params)
               .result
               .joins(order_products: :product)
               .group("products.name, stocks.product_id")
               .select("stocks.product_id, products.name, SUM(order_products.quantity) as product_quantity")
               .order("product_quantity DESC")
               .first(5)
               .map { |product| [ product.name, product.product_quantity ] }
               .to_h
  end
end
