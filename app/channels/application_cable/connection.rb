module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_company

    def connect
      self.current_user = find_verified_user
    end

    protected

    private

    def find_verified_user
      decoded = JwtService.decode(token).first

      @current_user = cache_user_session(decoded["user_id"])
      @current_company = cache_company_session(@current_user.company_id)

      @current_user
    end

    def token
      cookies.encrypted[:jwt]
    end

    def cache_user_session(user_id)
      Rails.cache.fetch("user_session_#{user_id}", expires_in: 3.minutes) { User.find(user_id) }
    end

    def cache_company_session(company_id)
      Rails.cache.fetch("company_session_#{company_id}", expires_in: 3.minutes) { Company.find(company_id) }
    end
  end
end
