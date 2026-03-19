class ReportJob < ApplicationJob
  sidekiq_options queue: :low

  def perform(user_id)
    user = User.find(user_id)

    Report.generate_sales_report!(user)
  end
end
