class Api::Dashboard::AgeController < Api::Dashboard::BaseController
  def index
    render json: { age: age || 999 }
  end

  private

  def age
    data = policy_scope(@current_company.clients)
      .where.not(birth_date: nil)
      .select("AVG((DATE_PART('year', AGE(birth_date)))) as client_age")
      .take
      .client_age&.to_f&.round(0)
  end
end
