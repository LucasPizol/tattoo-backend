class Api::PaymentMethodsController < Api::ApplicationController
  before_action :set_payment_method, only: %i[ show update destroy ]

  def index
    authorize(PaymentMethod, :index?)

    @payment_methods = policy_scope(@current_company.payment_methods).ransack(search_params).result.order(name: :asc)
  end

  def show
    authorize(@payment_method, :show?)
  end

  def create
    authorize(PaymentMethod, :create?)

    @payment_method = @current_company.payment_methods.build(payment_method_params.merge(user_id: current_user.id))

    if @payment_method.save
      render :show, status: :created
    else
      render_error(@payment_method)
    end
  end

  def update
    authorize(@payment_method, :update?)

    if @payment_method.update(payment_method_params)
      render :show, status: :ok
    else
      render_error(@payment_method)
    end
  end

  def destroy
    authorize(@payment_method, :destroy?)

    @payment_method.destroy!

    head :no_content
  end

  private
    def set_payment_method
      @payment_method = policy_scope(@current_company.payment_methods).find(params.expect(:id))
    end

    def payment_method_params
      params.expect(payment_method: [ :name, :taxes ])
    end

    def search_params
      params.fetch(:q, {}).permit(:name_cont)
    end
end
