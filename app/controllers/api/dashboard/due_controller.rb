class Api::Dashboard::DueController < Api::Dashboard::BaseController
  def index
    mapped_due = due.map do |due|
      {
        id: due.user_id,
        name: due.user_name,
        valueExpected: {
          value: due.value_expected_cents,
          currency: "BRL",
          formatted: Money.new(due.value_expected_cents, "BRL").format
        },
        valueReceived: {
          value: due.value_received_cents,
          currency: "BRL",
          formatted: Money.new(due.value_received_cents, "BRL").format
        }
      }
    end

    render json: { due: mapped_due }
  end

  private

  def due
    order_scope.joins(order_payments: { payments: :user }).ransack(search_params).result.where(status: :paid).select(
      "users.id as user_id",
      "users.name as user_name",
      "SUM(payments.value_expected_cents - payments.taxes_value_cents) as value_expected_cents",
      "SUM(payments.value_received_cents - payments.taxes_value_cents) as value_received_cents"
    ).group("users.id").order("value_expected_cents DESC")
  end
end
