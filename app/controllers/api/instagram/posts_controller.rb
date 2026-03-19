class Api::Instagram::PostsController < Api::ApplicationController
  include Pagination

  def index
    @instagram_posts = @current_company.instagram_posts.with_attached_contents
      .includes(:account)
      .order("created_at DESC")
      .paginate(page, per_page)
  end

  def show
    @instagram_post = @current_company.instagram_posts.with_attached_contents.find(params[:id])
  end

  def create
    @instagram_posts = []

    ActiveRecord::Base.transaction do
      post_params[:instagram_account_ids].each do |instagram_account_id|
        @instagram_posts << create_instagram_post_for(instagram_account_id)
      end
    end

    head :created
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def publish
    @instagram_post = @current_company.instagram_posts.find(params[:id])
    @instagram_post.publish
    render :show, status: :ok
  end

  def update
    @instagram_post = @current_company.instagram_posts.find(params[:id])

    if @instagram_post.update(post_params.except(:contents))
      @instagram_post.contents.attach(post_params[:contents]) if post_params[:contents].present?

      render :show, status: :ok
    else
      render_error(@instagram_post)
    end
  end

  def destroy
    @instagram_post = @current_company.instagram_posts.find(params[:id])
    @instagram_post.destroy!
    head :no_content
  end

  private

  def create_instagram_post_for(id)
    @instagram_post = @current_company.instagram_posts.build(post_params.except(:instagram_account_ids))
    @instagram_post.account = accounts.find { |account| account.id == id.to_i }
    @instagram_post.save!
    @instagram_post
  end

  def accounts
    @accounts ||= @current_company.company_instagram_accounts.where(id: post_params[:instagram_account_ids])
  end

  def post_params
    params.expect(post: [ :caption, contents: [], instagram_account_ids: [] ])
  end
end
