class Api::ProductsController < Api::ApplicationController
  include Pagination

  before_action :set_product, only: %i[ show update destroy ]

  def index
    authorize(Product, :index?)

    formatted_params = search_params.dup

    if formatted_params[:user_id_eq].present? && formatted_params[:user_id_eq] === "-1"
      formatted_params.delete(:user_id_eq)
      formatted_params[:user_id_null] = true
    end

    @products = policy_scope(@current_company.products)
                            .with_attached_images
                            .includes(:images_blobs)

    if formatted_params[:without_stock].present?
      @products = @products.without_stock
    end

    if formatted_params[:name_cont].present?
      @products = @products.search_by_name(formatted_params[:name_cont])
    end

    @products = @products.ransack(formatted_params.except(:without_stock, :name_cont)).result
                         .includes(:material, :tags, :stocks, :user)
                         .order(name: :asc)
                         .paginate(page, per_page)
  end

  def show
    authorize(@product, :show?)

    render :show
  end

  def create
    @product = @current_company.products.build(product_params.except(:tag_ids, :images, :quantity).merge(cost_value: Money.new(0, "BRL")))

    has_initial_stock = product_params[:quantity].present? && product_params[:quantity].to_i > 0

    Product.transaction do
      stock = @product.stocks.build
      stock.stock_movements.build(quantity: product_params[:quantity], company: @current_company, movement_type: "in", value: 0.01) if has_initial_stock

      @product.tags = @current_company.tags.where(id: product_params[:tag_ids])
      @product.images.attach(product_params[:images]) if product_params[:images].present?
      @product.save!
    end
  rescue ActiveRecord::RecordInvalid => e
    render_error(@product)
  end

  def update
    @product.tags = @current_company.tags.where(id: product_params[:tag_ids]) if product_params[:tag_ids].present?
    @product.images.attach(product_params[:images]) if product_params[:images].present?

    if @product.update(product_params.except(:tag_ids, :images, :quantity).merge(value: product_params[:value].gsub(".", ","), user_id: product_params[:user_id] == "undefined" ? nil : product_params[:user_id]))
      render :show, status: :ok
    else
      render_error(@product)
    end
  end

  def destroy
    @product.destroy!

    head :no_content
  end

  private

  def set_product
    @product = policy_scope(@current_company.products).find(params.expect(:id))
  end

  def product_params
    params.expect(product: [ :name, :material_id, :user_id, :value, :quantity, :require_responsible, :quantity, :product_type, :featured, :new, :carousel, tag_ids: [], images: [] ])
  end

  def search_params
    params.fetch(:q, {}).permit(:name_cont, :value_gteq, :value_lteq, :quantity_gteq, :quantity_lteq, :material_id_eq, :product_type_eq, :featured_eq, :new_eq, :carousel_eq, :stocks_user_id_eq, :without_stock)
  end
end
