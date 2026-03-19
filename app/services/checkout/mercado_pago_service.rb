require "mercadopago"

class Checkout::MercadoPagoService
  PAYMENT_STATUS_MAP = {
    "approved" => :paid,
    "rejected" => :failed,
    "cancelled" => :canceled,
    "refunded" => :refunded,
    "in_progress" => :processing,
    "in_process" => :processing
  }

  def initialize
    @sdk = Mercadopago::SDK.new(ENV.fetch("MERCADOPAGO_ACCESS_TOKEN"))
  end

  def create_preference(items)
    preference_response = @sdk.preference.create({ items: items })
    preference = preference_response [:response]
    preference["id"]
  end

  def get_payment(payment_id)
    payment_response = @sdk.payment.get(payment_id)
    payment_response[:response]
  end

  def create_payment(order, token:, payer: nil, installments: 1)
    shipping = build_shipping(order)

    payment_response = @sdk.payment.create({
      transaction_amount: order.total_value_with_shipping.to_f,
      token: token,
      payer: payer,
      installments: installments,
      external_reference: order.id,
      description: "Pedido #{order.id}",
      additional_info: {
        items: order.order_products.includes(stock: :product).map do |product|
          image = product.stock.product.images.first
          image_url = "https://rainbow-piercing-bucket-v2.s3.amazonaws.com/#{image.key}"

          {
            title: product.stock.product.name,
            unit_price: product.stock.product.value.to_f,
            quantity: product.quantity,
            description: product.stock.product.description,
            picture_url: image_url
          }
        end
      }.tap { it[:shipments] = shipping if shipping.present? }
    })

    if payment_response[:status] != 201
      raise "Erro ao criar pagamento: #{payment_response[:response]}"
    else
      payment = payment_response[:response]
      payment
    end
  end

  def create_terminal_order(order, terminal_id:, default_installments: 6, installments_cost: "buyer")
    payment_method = order.user_comissions.first&.payment_method

    body = {
      type: "point",
      external_reference: order.id.to_s,
      transactions: {
        payments: [
          {
            amount: order.total_value.to_f
          }
        ]
      },
      config: {
        point: {
          terminal_id: terminal_id
        },
        payment_method: {
          default_type: payment_method&.external_type || :credit_card,
          default_installments: default_installments,
          installments_cost: installments_cost
        }
      }
    }.to_json

    order_response = http_client.post("/v1/orders", body)

    raise "Erro ao criar pedido: #{order_response.body}" if order_response.status != 201

    JSON.parse(order_response.body)
  end

  def list_terminals
    if Rails.env.development?
      return [
        Struct.new(:id, :pos_id, :store_id, :external_pos_id, :operating_mode).new(1, "1234567890", "1234567890", "1234567890", "point"),
        Struct.new(:id, :pos_id, :store_id, :external_pos_id, :operating_mode).new(2, "1234567890", "1234567890", "1234567890", "point"),
        Struct.new(:id, :pos_id, :store_id, :external_pos_id, :operating_mode).new(3, "1234567890", "1234567890", "1234567890", "point")
      ]
    end

    Rails.cache.fetch("mercado_pago_terminals", expires_in: 24.hours) do
      terminals_response = http_client.get("/terminals/v1/list")

      JSON.parse(terminals_response.body)["data"]["terminals"].map do |terminal|
        Struct.new(:id, :pos_id, :store_id, :external_pos_id, :operating_mode).new(terminal["id"], terminal["pos_id"], terminal["store_id"], terminal["external_pos_id"], terminal["operating_mode"])
      end
    end
  end

  private

  def build_shipping(order)
    return nil if order.shipping.blank?

    address = order.address

    return nil if address.blank?

    {
      receiver_address: {
        zip_code: address.zipcode,
        state_name: address.state,
        city_name: address.city,
        street_name: address.street,
        street_number: address.number
      }
    }
  end

  def http_client
    @http_client ||= Faraday.new(url: "https://api.mercadopago.com") do |faraday|
      faraday.headers["Authorization"] = "Bearer #{ENV.fetch("MERCADOPAGO_ACCESS_TOKEN")}"
    end
  end
end
