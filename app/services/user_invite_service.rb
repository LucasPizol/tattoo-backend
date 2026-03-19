class UserInviteService
  def self.invite(user_invite)
    user_invite.user_invite_tokens.update_all(enabled: false)
    token = user_invite.user_invite_tokens.create!(token: SecureRandom.hex(10), enabled: true)
    url = "#{ENV.fetch("FRONTEND_URL")}/aceitar-convite/#{token.token}"

    sended = Whatsapp::Client.new.send_url(
      phone: user_invite.phone,
      message: "Você foi convidado para ser um usuário da nossa plataforma. Clique no botão abaixo para aceitar o convite.",
      url: url,
      display_text: "Aceitar convite",
      header: "Convite para Estúdio Glamour",
      footer: "Clique no botão abaixo para aceitar o convite."
    )

    puts "sended: #{sended}"

    sended
  end

  def self.accept(token, password:, name:)
    user_invite_token = UserInviteToken.find_by(token: token, enabled: true)

    return false if user_invite_token.blank?

    user_invite = user_invite_token.user_invite

    return false if user_invite.blank?

    ActiveRecord::Base.transaction do
      user = User.create!(
        username: user_invite.phone,
        password: password,
        name: name,
        role: user_invite.role,
        company: user_invite.company,
        commission_percentage: user_invite.commission_percentage
      )

      Contract.create!(
        user: user,
        content: ContractContentService.generate(user: user, commission_percentage: user_invite.commission_percentage),
        version: ContractContentService::CURRENT_VERSION
      )

      user_invite_token.update_column(:enabled, false)
      user_invite.update_column(:status, :accepted)
    end

    true
  end
end
