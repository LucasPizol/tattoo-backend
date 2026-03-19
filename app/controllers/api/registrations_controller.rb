class Api::RegistrationsController < Api::ApplicationController
  skip_before_action :authenticate_request, only: %i[create]

  def create
    @company = Company.new(name: registration_params[:company_name], cnpj: registration_params[:cnpj])
    @user = @company.users.build(
      name: registration_params[:full_name],
      username: registration_params[:email],
      password: registration_params[:password],
    )
    @company.build_company_config

    ActiveRecord::Base.transaction do
      @company.save!
      admin_role = Roles::SeedAdminRoleService.new(@company).call
      @user.role = admin_role
      @user.save!
    end

    @user.generate_refresh_token

    set_cookie(@user.id, refresh_token: @user.refresh_token, refresh_token_expires_at: @user.refresh_token_expires_at)

    render "api/sessions/show", status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_error(@company, @user)
  end

  private

  def registration_params
    params.require(:registration).permit(:company_name, :cnpj, :full_name, :email, :password)
  end
end
