class Api::GoogleAuthController < Api::ApplicationController
  skip_before_action :authenticate_request, only: %i[authenticate complete_registration]

  def authenticate
    google_data = verify_google_access_token(params[:access_token])
    return render json: { message: "Token do Google inválido" }, status: :unauthorized unless google_data

    email = google_data["email"]
    google_uid = google_data["sub"]
    name = google_data["name"]

    @user = User.find_by(username: email) || User.find_by(google_uid: google_uid)

    if @user.present?
      @user.update_column(:google_uid, google_uid) if @user.google_uid.blank?
      @user.generate_refresh_token
      set_cookie(@user.id, refresh_token: @user.refresh_token, refresh_token_expires_at: @user.refresh_token_expires_at)
      render "api/sessions/show"
    else
      render json: {
        needs_company_info: true,
        google_data: {
          google_uid: google_uid,
          email: email,
          name: name
        }
      }
    end
  end

  def complete_registration
    @company = Company.new(
      name: complete_params[:company_name],
      cnpj: complete_params[:cnpj]
    )
    @user = @company.users.build(
      name: complete_params[:name],
      username: complete_params[:email],
      google_uid: complete_params[:google_uid],
      password: SecureRandom.hex(32)
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

  def verify_google_access_token(access_token)
    return nil if access_token.blank?

    response = HTTParty.get(
      "https://www.googleapis.com/oauth2/v3/userinfo",
      headers: { "Authorization" => "Bearer #{access_token}" }
    )
    return nil unless response.code == 200

    data = response.parsed_response
    return nil unless data["email_verified"] == true || data["email_verified"] == "true"

    data
  rescue StandardError
    nil
  end

  def complete_params
    params.require(:google_registration).permit(:company_name, :cnpj, :name, :email, :google_uid)
  end
end
