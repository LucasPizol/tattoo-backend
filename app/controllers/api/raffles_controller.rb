class Api::RafflesController < Api::ApplicationController
  include Pagination
  before_action :set_raffle, only: %i[show destroy]

  def index
    authorize(Raffle, :index?)

    @raffles = @current_company.raffles.order(created_at: :desc).paginate(page, per_page)
    render :index
  end

  def show
    authorize(@raffle, :show?)

    render :show
  end

  def create
    authorize(Raffle, :create?)

    @raffle = @current_company.raffles.build(raffle_params)

    @raffle.filters = {} if @raffle.instagram_post.present?

    ActiveRecord::Base.transaction do
      @raffle.save!
      @raffle.perform_draw!
    end

    render :show, status: :created
  rescue ActiveRecord::RecordInvalid
    render_error(@raffle)
  end

  def destroy
    authorize(@raffle, :destroy?)

    @raffle.destroy!
    head :no_content
  end

  private

  def set_raffle
    @raffle = @current_company.raffles.find(params.expect(:id))
  end

  def raffle_params
    permitted = params.require(:raffle).permit(
      :name, :description, :primary_count, :secondary_count, :instagram_post_id,
      filters: [ :start_date, :end_date, :min_order_value, { product_ids: [] } ]
    )
    permitted[:filters] = permitted[:filters]&.to_h
    permitted
  end
end
