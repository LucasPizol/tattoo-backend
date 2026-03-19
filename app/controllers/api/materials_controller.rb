class Api::MaterialsController < Api::ApplicationController
  before_action :set_material, only: %i[ show update destroy ]

  def index
    authorize(Material, :index?)

    @materials = policy_scope(@current_company.materials).ransack(search_params).result.order(name: :asc)
  end

  def show
    authorize(@material, :show?)
  end

  def create
    authorize(Material, :create?)

    @material = @current_company.materials.build(material_params.merge(user_id: current_user.id))

    if @material.save
      render :show, status: :created
    else
      render_error(@material)
    end
  end

  def update
    authorize(@material, :update?)

    if @material.update(material_params)
      render :show, status: :ok
    else
      render_error(@material)
    end
  end

  def destroy
    authorize(@material, :destroy?)

    @material.destroy!

    head :no_content
  end

  private
    def set_material
      @material = policy_scope(@current_company.materials).find(params.expect(:id))
    end

    def material_params
      params.expect(material: [ :name, :notes ])
    end

    def search_params
      params.fetch(:q, {}).permit(:name_cont)
    end
end
