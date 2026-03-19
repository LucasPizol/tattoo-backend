class Api::StocksController < Api::ApplicationController
  def create
    authorize(Stock, :create?)

    stock_params.each do |stock_param|
      stock_id = stock_param[:stock_id]

      quantity = stock_param.expect(:quantity)

      product = policy_scope(@current_company.products).find(stock_param[:product_id])

      stock = stock_id.present? ? Stock.find(stock_id) : Stock.find_or_create_by!(product: product)

      difference = quantity - stock.quantity

      if difference > 0
        stock.stock_movements.build(quantity: difference.abs, company: @current_company, movement_type: "in", value: 0.01, notes: "Ajuste de estoque")
      elsif difference < 0
        stock.stock_movements.build(quantity: difference.abs, company: @current_company, movement_type: "out", value: 0.01, notes: "Ajuste de estoque")
      end

      stock.save!
    end

    head :created
  end

  private

  def stock_params
    params.fetch(:stock, [ [ :stock_id, :quantity, :product_id ] ])
  end
end
