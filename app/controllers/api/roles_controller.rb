class Api::RolesController < Api::ApplicationController
  before_action :set_role, only: %i[show update destroy]

  def index
    authorize(Role, :index?)
    @roles = current_company.roles
    render :index
  end

  def show
    authorize(@role, :show?)
  end

  def create
    authorize(Role, :create?)

    @role = current_company.roles.build(role_params)
    @role.save ? render(:show, status: :created) : render_error(@role)
  end

  def update
    authorize(@role, :update?)

    @role.update(role_params) ? render(:show) : render_error(@role)
  end

  def destroy
    authorize(@role, :destroy?)

    @role.destroy!
    head :no_content
  end

  def available_permissions
    authorize(Role, :available_permissions?)

    render :available_permissions
  end

  private

  def set_role
    @role = current_company.roles.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name)
  end
end
