class OrderMailer < ApplicationMailer
  default from: "lucaspizolfe@gmail.com"

  def order_received(order)
    @order = order
    @client = order.client

    return if @client&.email.blank?

    @aggregated_products = order.order_products.includes(stock: :product).group_by { |op| op.stock.product.id }.map do |product_id, order_products|
      product = order_products.first.stock.product
      total_quantity = order_products.sum(&:quantity)

      {
        id: product.id,
        name: product.name,
        slug: product.slug,
        quantity: total_quantity,
        value: order_products.first.value.format,
        total_value: ((order_products.first.value) * total_quantity).format,
        images: product.build_image_data,
        material_name: product.material&.name,
        thumbnail_url: product.thumbnail_url(product.images.first)
      }
    end

    @payment = order.payments.client.first
    @total_value = order.total_client_value
    @shipping = order.shipping

    mail(
      to: @client.email,
      subject: "Pedido ##{@order.id} recebido com sucesso! 🎉"
    )
  rescue => e
    Rails.logger.error("Error sending order received email: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end
end
