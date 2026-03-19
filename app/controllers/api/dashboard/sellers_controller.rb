class Api::Dashboard::SellersController < Api::Dashboard::BaseController
  def index
    render json: {
      sellers: by_sellers
    }
  end

  private

  def by_sellers
    order_scope.ransack(search_params).result.where(status: :paid)

    data = order_scope.joins(:user)
      .joins(:user, :comissions)
      .select(
        "users.id as user_id",
        "users.name as user_name",
        "SUM(comissions.value_cents) as comission_value_cents",
        "SUM(orders.product_values_subcents) as product_values_subcents"
      ).group("users.id").order("product_values_subcents DESC")

    data.map do |seller|
      {
        id: seller.user_id,
        name: seller.user_name,
        comissionToPay: {
          value: seller.comission_value_cents,
          currency: "BRL",
          formatted: Money.new(seller.comission_value_cents, "BRL").format
        },
        productIncome: {
          value: seller.product_values_subcents,
          currency: "BRL",
          formatted: Money.new(seller.product_values_subcents, "BRL").format
        }
      }
    end
  end
end
