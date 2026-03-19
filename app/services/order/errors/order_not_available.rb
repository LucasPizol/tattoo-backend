class Order::Errors::OrderNotAvailable < StandardError
  def initialize(message = "Order is already processed or is still processing")
    super(message)
  end
end
