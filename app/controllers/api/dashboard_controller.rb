class Api::DashboardController < ApplicationController
  def index
  end

  private

  def order_count
    @current_company.orders.count
  end

  def client_count
    @current_company.clients.count
  end

  def current_month_order_entries
    @current_company.orders.current_month.sum(:product_value_subcents) / 100
  end

  def current_month_products_total
    @current_company.orders.current_month.joins(:order_products).sum("order_products.quantity")
  end

  def values_evolution
    data = @current_company.orders.group("TO_CHAR(created_at, 'MM')").sum(:product_values_subcents).transform_values { |v| v / 100 }

    initial_hash = {
      "01" => 0,
      "02" => 0,
      "03" => 0,
      "04" => 0,
      "05" => 0,
      "06" => 0,
      "07" => 0,
      "08" => 0,
      "09" => 0,
      "10" => 0,
      "11" => 0,
      "12" => 0
    }

    data.each do |key, value|
      initial_hash[key] = value
    end

    initial_hash
  end
end
