module Pagination
  extend ActiveSupport::Concern

  def page
    @current_page ||= params[:page]&.to_i || 1
  end

  def per_page
    @per_page ||= params[:per_page]&.to_i || 10
  end
end
