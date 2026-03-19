class Api::IndicationsController < Api::ApplicationController
  ALLOWED_SORTS = {
    "total_value desc" => "total_value DESC",
    "total_value asc" => "total_value ASC",
    "total_orders desc" => "total_orders DESC",
    "total_orders asc" => "total_orders ASC",
    "total_indications desc" => "total_indications DESC",
    "total_indications asc" => "total_indications ASC",
    "total_indications_who_bought desc" => "total_indications_who_bought DESC",
    "total_indications_who_bought asc" => "total_indications_who_bought ASC",
    "name desc" => "name DESC",
    "name asc" => "name ASC"
  }.freeze

  def index
    authorize(Client, :index?)

    @indications = @current_company.clients.with_report_indications

    if search_params[:s].present? && ALLOWED_SORTS.key?(search_params[:s])
      @indications = @indications.order(Arel.sql(ALLOWED_SORTS[search_params[:s]]))
    end

    render :index
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:s)
  end
end
