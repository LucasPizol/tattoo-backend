class Api::Dashboard::ClientSellsController < Api::Dashboard::BaseController
  def index
    render json: { clientSells: client_sells }
  end

  private

  def client_sells
    order_scope.paid.ransack(search_params).result
      .left_joins(client: :responsible)
      .select(
        :client_id,
        "clients.name as client_name",
        "responsibles.name as responsible_name",
        "responsibles.id as responsible_id",
        "clients.birth_date as client_birth_date",
        "COALESCE(SUM(orders.product_values_subcents), 0) as summed_value"
      )
      .where.not(client_id: nil)
      .group(:client_id, :client_name, :responsible_name, :responsible_id, :client_birth_date)
      .order("summed_value DESC")
      .first(5)
      .map do |order|
        client = order.client

        name = client.name
        name += " (#{client.responsible.name})" if client.lower_age? && client.responsible.present?

        [ name, order.summed_value ]
      end.to_h
  end
end
