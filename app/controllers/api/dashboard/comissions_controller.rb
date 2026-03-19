class Api::Dashboard::ComissionsController < Api::Dashboard::BaseController
  def index
    paid_orders = order_scope
      .ransack(search_params)
      .result
      .where(status: :paid)
      .includes(:client, comissions: :user)

    users_data = {}

    puts "paid_orders: #{paid_orders.inspect}"

    paid_orders.find_each do |order|
      order.comissions.each do |comission|
        next unless comission.user_id.present?

        user = comission.user
        users_data[user.id] ||= {
          id: user.id,
          name: user.name,
          commission_percentage: user.commission_percentage.abs,
          payer: comission.payer,
          total_value_cents: 0,
          orders_count: 0,
          orders: []
        }

        users_data[user.id][:total_value_cents] += comission.value_cents
        users_data[user.id][:orders_count] += 1
        users_data[user.id][:orders] << {
          id: order.id,
          client_name: order.client&.name || "Não informado",
          product_value: format_money(order.product_values_subcents),
          commission_value: format_money(comission.value_cents),
          commission_percentage: comission.percentage.to_f,
          paid_at: order.paid_at&.strftime("%d/%m/%Y")
        }
      end
    end

    total_to_pay = users_data.values
      .select { |u| u[:payer] == "user" }
      .sum { |u| u[:total_value_cents] }

    total_to_receive = users_data.values
      .select { |u| u[:payer] == "company" }
      .sum { |u| u[:total_value_cents] }

    render json: {
      users: users_data.values.map { |u|
        u.merge(
          total_value: format_money(u[:total_value_cents])
        )
      },
      summary: {
        total_to_pay: format_money(total_to_pay),
        total_to_receive: format_money(total_to_receive),
        balance: format_money(total_to_receive - total_to_pay)
      }
    }
  end

  private

  def format_money(cents)
    {
      value: cents,
      currency: "BRL",
      formatted: Money.new(cents, "BRL").format
    }
  end
end
