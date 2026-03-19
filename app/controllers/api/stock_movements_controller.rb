class Api::StockMovementsController < Api::ApplicationController
  include Pagination

  before_action :set_stock_movement, only: %i[ show destroy ]

  def index
    @stock_movements = policy_scope(@current_company.stock_movements).ransack(search_params).result.includes(:order, stock: :product).order(created_at: :desc).paginate(page, per_page)
  end

  def show
    authorize(@stock_movement, :show?)

    render :show
  end

  def create
    authorize(StockMovement, :create?)

    product = Product.find(stock_movement_params[:product_id])

    stock = Stock.find_or_create_by!(product: product)

    @stock_movement = stock.stock_movements.build(stock_movement_params.except(:product_id).merge(company: @current_company, order: nil))

    if @stock_movement.save
      render :show, status: :created
    else
      render_error(@stock_movement)
    end
  end

  def destroy
    authorize(@stock_movement, :destroy?)

    @stock_movement.destroy!

    head :no_content
  end

  private
    def set_stock_movement
      @stock_movement = policy_scope(@current_company.stock_movements).find(params.expect(:id))
    end

    def stock_movement_params
      params.expect(stock_movement: [ :product_id, :quantity, :value, :movement_type, :notes, :user_id ])
    end

    def search_params
      params.fetch(:q, {}).permit(:product_name_cont, :created_at_gteq, :created_at_lteq, movement_type_in: [])
    end
end
