class Order::Processor
  include ServiceObject

  arguments :order

  def call
    order.with_lock do
      order.paid_at = Time.current
      order.save!(validate: false)
      create_stock_movements
      create_sale_message_calendar_events
    end

    order.send_email_confirmation_message
    order.send_confirmation_message
  end

  def create_stock_movements
    order.order_products.each do |order_product|
      StockMovement.create!(
        stock: order_product.stock,
        quantity: order_product.quantity.abs,
        value: order_product.value,
        movement_type: order_product.quantity.positive? ? :out : :in,
        company: order.company,
        order: order
      )
    end
  end

  def create_sale_message_calendar_events
    order.sale_messages.each do |sale_message|
      start_at = sale_message.scheduled_at + 10.hours
      end_at =   sale_message.scheduled_at + 11.hours

      order.calendar_events.create!(title: "Retorno de #{sale_message.client.name}", description: "Retorno de #{sale_message.client.name} para verificar como está a perfuração", start_at: start_at, end_at: end_at, event_type: :repair, status: :pending, order: order, company: order.company, phone: sale_message.client.phone, send_whatsapp_message: true)
    end
  end
end
