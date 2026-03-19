class Api::Dashboard::TagsController < Api::Dashboard::BaseController
  def index
    render json: { tags: tags }
  end

  private

  def tags
    order_scope.paid.ransack(search_params).result.joins(order_products: { product: :tags }).group("tags.name").sum("order_products.quantity").first(5).to_h
  end
end
