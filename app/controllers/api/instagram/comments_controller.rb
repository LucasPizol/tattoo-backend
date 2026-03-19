class Api::Instagram::CommentsController < Api::ApplicationController
  include Pagination

  def index
    @instagram_comments = Instagram::Comment
      .where(instagram_post_id: @current_company.instagram_posts.select(:id))
      .includes(:post, :account)
      .ransack(params[:q]).result
      .paginate(page, per_page)
  end
end
