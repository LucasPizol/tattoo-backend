class Api::UserInvitesController < Api::ApplicationController
  skip_before_action :authenticate_request, only: [ :accept ]

  def index
    user_invites = current_company.user_invites

    render json: { userInvites: user_invites.map { |user_invite| { id: user_invite.id, phone: user_invite.phone, status: user_invite.status, commission_percentage: user_invite.commission_percentage } } }, status: :ok
  end

  def create
    user_invite = current_company.user_invites.create!(phone: params[:phone], role: current_company.roles.find(params[:role]), commission_percentage: params[:commission_percentage])

    InviteUserJob.perform_async(user_invite.id)

    render json: { message: "Convite enviado com sucesso" }, status: :ok
  end

  def accept
    user_invite = UserInviteService.accept(request.headers["X-Invite-Token"], password: params[:password], name: params[:name])

    if user_invite
      render json: { message: "Convite aceito com sucesso" }, status: :ok
    else
      render json: { message: "Convite inválido ou expirado" }, status: :unprocessable_entity
    end
  end

  def resend
    user_invite = UserInvite.find(params[:id])

    InviteUserJob.perform_async(user_invite.id)

    render json: { message: "Convite reenviado com sucesso" }, status: :ok
  end
end
