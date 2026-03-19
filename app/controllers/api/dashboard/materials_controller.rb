class Api::Dashboard::MaterialsController < Api::Dashboard::BaseController
  def index
    render json: { materials: materials }
  end

  private

  def materials
    order_scope.paid.ransack(search_params).result.joins(order_products: { product: :material }).group("materials.name").sum("order_products.quantity").first(5).to_h
  end
end
