class Api::OrdersController < Api::ApplicationController
  include Pagination
  before_action :set_order, only: %i[ show update destroy reopen ]

  def index
    authorize(Order, :index?)

    scope = policy_scope(@current_company.orders)

    @orders = scope.ransack(prepare_search_params)
                   .result
                   .includes(:comissions, :payment_methods, client: :responsible)
                   .order(created_at: :desc)
                   .paginate(page, per_page)
  end

  def show
    authorize(@order, :show?)
  end

  def create
    authorize(Order, :create?)

    @order = @current_company.orders.build(status: :pending, product_value: 0, taxes_value: 0, user_id: @current_user.id, local_pickup: true)

    unless @current_user.commission_percentage.zero?
      comission = @order.comissions.build(
        user: @current_user,
        name: "Comissão do usuário",
        percentage: @current_user.commission_percentage.abs,
        payer: @current_user.pays_comissions? ? :user : :company,
      )
      comission.calculate_value
    end

    if @order.save
      render :show, status: :created
    else
      render_error(@order)
    end
  end

  def update
    authorize(@order, :update?)

    if @order.update!(order_params)
      Order::Processor.call(order: @order) if @order.paid?

      render :show, status: :ok
    else
      render_error(@order)
    end
  end

  def destroy
    authorize(@order, :destroy?)

    @order.destroy!

    head :no_content
  end

  def reopen
    authorize(@order, :reopen?)

    @order.reopen

    render :show, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render_error(@order)
  end

  private
    def set_order
      @order = policy_scope(@current_company.orders).find(params.expect(:id))
    end

    def order_params
      params.expect(order: [ :status, :client_id, :address_id, :skip_greeting_message, :iris_part, :jennipher_part, :taxes_value, :values_divided ])
    end

    def search_params
      params.fetch(:q, {}).permit(:client_name_or_client_email_or_client_phone_or_client_cpf_cont,
                                  :created_at_gteq, :created_at_lteq,
                                  :client_id_eq, :created_by_eq,
                                  :paid_at_gteq, :paid_at_lteq,
                                  status_in: [])
    end

    def prepare_search_params
      copied_params = search_params.dup

      if copied_params[:status_in].present?
        copied_params[:status_in] = copied_params[:status_in].map { |status| Order.statuses[status] }
      end

      if copied_params[:created_by_eq].present?
        copied_params[:created_by_eq] = Order.created_bies[copied_params[:created_by_eq]]
      end

      if copied_params[:created_at_gteq].present?
        copied_params[:created_at_gteq] = copied_params[:created_at_gteq].to_date.beginning_of_day
      end

      if copied_params[:created_at_lteq].present?
        copied_params[:created_at_lteq] = copied_params[:created_at_lteq].to_date.end_of_day
      end

      if copied_params[:paid_at_gteq].present?
        copied_params[:paid_at_gteq] = copied_params[:paid_at_gteq].to_date.beginning_of_day
      end

      if copied_params[:paid_at_lteq].present?
        copied_params[:paid_at_lteq] = copied_params[:paid_at_lteq].to_date.end_of_day
      end

      copied_params
    end
end
