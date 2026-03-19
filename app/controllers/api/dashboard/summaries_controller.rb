class Api::Dashboard::SummariesController < Api::Dashboard::BaseController
  INCLUDE_COST = false

  def index
    if INCLUDE_COST
      data = {
        income: Money.new(summary.product_values_subcents, "BRL").format,
        cost: Money.new(summary.cost_value_subcents, "BRL").format,
        profit: Money.new(summary.product_values_subcents - summary.cost_value_subcents, "BRL").format
      }

      render json: { summary: data }
    else
      render json: { summary: Money.new(summary, "BRL").format }
    end
  end

  private

  def summary
    @summary ||= begin
      if INCLUDE_COST
        scope = order_scope.paid.ransack(search_params).result.select(
          "SUM(orders.product_values_subcents) as product_values_subcents",
          "SUM(orders.cost_value_subcents) as cost_value_subcents"
        )
      else
        scope = order_scope.paid.ransack(search_params).result.select(
          "(SUM(orders.product_values_subcents) -
           SUM(orders.applied_birth_date_discount_percentage * orders.product_values_subcents / 100) -
           SUM(orders.comissions_value_cents) -
           SUM(CASE WHEN orders.paid_at >= '#{Order::TAXES_DEADLINE_DATE.to_fs(:db)}' THEN orders.taxes_values_subcents ELSE 0 END)) as product_values_subcents"
        )
        scope.group("orders.id").map(&:product_values_subcents).sum
      end
    end
  end
end
