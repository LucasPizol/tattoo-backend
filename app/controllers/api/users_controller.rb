class Api::UsersController < Api::ApplicationController
  def index
    authorize(User, :index?)

    @users = @current_company.users.includes(:contracts)
  end

  def update
    authorize(User, :update?)

    user = @current_company.users.find(params[:id])
    user.update!(update_params)

    render json: { message: "Usuário atualizado com sucesso" }, status: :ok
  end

  private

  def update_params
    params.permit(:commission_percentage, :role_id)
  end
end
