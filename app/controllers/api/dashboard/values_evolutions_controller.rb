class Api::Dashboard::ValuesEvolutionsController < Api::Dashboard::BaseController
  def index
    render json: { valuesEvolution: values_evolution, usersEvolution: users_evolution }
  end

  private

  def start_date
    search_params[:paid_at_gteq]&.to_date&.beginning_of_year || Time.current.beginning_of_year
  end

  def end_date
    search_params[:paid_at_lteq]&.to_date&.end_of_year || Time.current.end_of_year
  end

  def evolution_scope
    order_scope.paid.where.not(paid_at: nil)
  end

  def values_evolution
    evolution_scope.group("TO_CHAR(paid_at, 'YYYY-MM')").sum("product_values_subcents").transform_values { |v| v / 100.0 }
  end

  def users_evolution
    evolution_scope.group("TO_CHAR(paid_at, 'YYYY-MM')")
      .joins(:user)
      .select("SUM(orders.product_values_subcents) as value_cents, orders.user_id as id, users.name as name, TO_CHAR(paid_at, 'YYYY-MM') as month")
      .group("month, orders.user_id, users.name")
      .group_by { |group| group.id }
      .map do |user_id, groups|
        name = groups.first.name

        [ "#{user_id} - #{name.split.first}", groups.group_by { |group| group.month }.map { |month, groups| [ month, groups.sum { |group| group.value_cents } / 100.0 ] }.to_h ]
      end
      .to_h
  end
end
