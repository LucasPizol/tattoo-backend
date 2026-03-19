class Api::Dashboard::ProductTypesController < Api::Dashboard::BaseController
  def index
    render json: { productTypes: product_types }
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def product_types
    order_scope.paid
               .ransack(search_params)
               .result
               .joins(order_products: :product)
               .where("products.product_type IS NOT NULL")
               .group("products.product_type")
               .select("products.product_type, SUM(order_products.quantity) as product_quantity")
               .order("product_quantity DESC")
               .first(5)
               .map { |product_type| [ ProductType.find(product_type.product_type)[:label], product_type.product_quantity ] }
               .to_h
  end
end
