class Shipping::CostService
  ORIGIN_ZIPCODE = "37704080"
  BOX_SIZE = 15

  def self.run!(order)
    new(order).call
  end

  def initialize(order)
    @order = order
  end

  def call
    return [] if @order.address.blank?

    cep_destino = @order.address.zipcode
    total_value = @order.product_value.to_f

    cost = rand(10..30) * 100

    [
      {
        company: "Correios",
        cost: Money.new(cost, :brl),
        final_cost: Money.new(cost * 1.05, :brl),
        estimated_delivery: "2 dias úteis"
      }
    ]
  end
end
