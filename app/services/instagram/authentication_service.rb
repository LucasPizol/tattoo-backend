class Instagram::AuthenticationService
  include ClassLogger

  def self.call(code:, user:)
    new(code: code, user: user).call
  end

  def initialize(code:, user:)
    @code = code
    @user = user
  end

  def call
    client = Instagram::Client.new
    short_token = client.create_short_token(@code)
    long_token = client.create_long_token(short_token[:token])
    puts "long_token: #{long_token}"
    me = client.me(long_token[:token])

    instagram_account = Instagram::Account.find_or_initialize_by(ig_id: me[:id], company: @user.company)
    instagram_account.update!(
      ig_username: me[:username],
      ig_profile_picture_url: me[:profile_picture_url],
      ig_access_token: long_token[:token],
      ig_expires_at: long_token[:expires_at],
      company_account: true
    )

    Instagram::SynchronizeMediaJob.perform_async(instagram_account.id)
  rescue StandardError => e
    log_error("Error authenticating instagram: #{e.message}")
    raise e
  end
end
