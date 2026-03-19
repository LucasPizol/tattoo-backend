class InviteUserJob < ApplicationJob
  sidekiq_options queue: :default

  def perform(user_invite_id)
    user_invite = UserInvite.find(user_invite_id)
    UserInviteService.invite(user_invite)
  end
end
