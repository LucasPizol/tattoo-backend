class Checkout::RequestPayment
  include ClassLogger

  attr_reader :order, :params, :client, :error

  def initialize(order, params, client)
    @order = order
    @params = params
    @client = client
  end

  def call
    validate_items_stock
    update_client

    @order.client = client
    @order.external_id = checkout_order
    @order.taxes_value = mercado_pago_fee
    create_payment

    @order.save!

    case payment_status
    when :failed
      @order.failed!
    else
      @order.processing!
    end

    @success = true
  rescue => e
    @success = false
    @error = e.message
  end

  def success?
    @success
  end

  private

  def update_client
    if @client.cpf.blank? && !Client.exists?(cpf: params.dig(:payer, :identification_number))
      @client.update!(cpf: params.dig(:payer, :identification_number))
    end
  end

  def mercado_pago_fee
    @mercado_pago_fee ||= checkout_order["fee_details"].find { |fee| fee["type"] == "mercadopago_fee" }["amount"]
  end

  def taxes_value
    @taxes_value ||= checkout_order["fee_details"].select { it["type"] != "mercadopago_fee" }.sum { it["amount"] }
  end

  def payer
    payer = {
      email: params.dig(:payer, :email),
      identification: {
        type: params.dig(:payer, :identification_type),
        number: params.dig(:payer, :identification_number)
      }
    }

    payer_name = "#{params.dig(:payer, :first_name)} #{params.dig(:payer, :last_name)}".strip
    payer[:name] = payer_name if payer_name.present?

    payer
  end

  def create_payment
    transaction_details = checkout_order["transaction_details"]

    Client::Payment.create!(
      order: @order,
      value: transaction_details["total_paid_amount"],
      installments: params.dig(:payment, :installments),
      cardholder_name: params.dig(:payment, :cardholder_name),
      last_four_digits: params.dig(:payment, :last_four_digits),
      payment_type: params.dig(:payment, :payment_type),
      net_received_value: transaction_details["net_received_amount"],
      total_paid_amount: transaction_details["total_paid_amount"],
      installment_amount: transaction_details["installment_amount"],
      taxes_value: taxes_value,
      external_id: checkout_order["id"],
      status: payment_status,
      owner: :client
    )
  end

  def payment_status
    Checkout::MercadoPagoService::PAYMENT_STATUS_MAP[checkout_order["status"]]
  end

  def checkout_order
    @checkout_order ||= Checkout::MercadoPagoService.new.create_payment(
      @order.reload,
      token: params[:token],
      payer: payer,
      installments: params.dig(:payment, :installments)
    )
  end

  def validate_items_stock
    @order.order_products.includes(stock: :product).each do |order_product|
      if order_product.stock.quantity < order_product.quantity
        raise "Quantidade insuficiente em estoque para o produto #{order_product.stock.product.name}"
      end
    end
  end
end
