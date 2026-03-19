class Api::PermissionsController < Api::ApplicationController
  before_action :set_role

  def update
    permission_names = params[:permissions] || []
    ActiveRecord::Base.transaction do
      @role.permissions.destroy_all
      @role.permissions.create!(permission_names.map { |name| { name: name } })
    end
    render json: { permissions: @role.permissions.pluck(:name) }, status: :ok
  end

  private

  def set_role
    @role = current_company.roles.find(params[:role_id])
  end
end
