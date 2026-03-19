class Api::Dashboard::BaseController < Api::ApplicationController
  protected

  def search_params
    params.fetch(:q, {}).permit(:paid_at_gteq, :paid_at_lteq)

    {
      paid_at_gteq: params.dig(:q, :paid_at_gteq)&.to_date&.beginning_of_day,
      paid_at_lteq: params.dig(:q, :paid_at_lteq)&.to_date&.end_of_day
    }
  end

  def order_scope
    policy_scope(@current_company.orders)
  end
end
