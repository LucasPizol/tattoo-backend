class Api::TagsController < Api::ApplicationController
  before_action :set_tag, only: %i[ show update destroy ]

  def index
    authorize(Tag, :index?)

    @tags = Tag.build_tree(@current_company.id)
  end

  def show
    authorize(@tag, :show?)

    render :show
  end

  def create
    authorize(Tag, :create?)

    @tag = @current_company.tags.build(tag_params)

    if @tag.save
      render :show, status: :created
    else
      render_error(@tag)
    end
  end

  def update
    authorize(@tag, :update?)

    if @tag.update(tag_params)
      render :show, status: :ok
    else
      render_error(@tag)
    end
  end

  def destroy
    authorize(@tag, :destroy?)

    @tag.destroy!

    head :no_content
  end

  private

  def set_tag
    @tag = policy_scope(@current_company.tags).find(params.expect(:id))
  end

  def tag_params
    params.expect(tag: [ :name, :notes, :tag_id ])
  end
end
