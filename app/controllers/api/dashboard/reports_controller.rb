# frozen_string_literal: true

class Api::Dashboard::ReportsController < Api::Dashboard::BaseController
  def index
    render json: { report: report }
  end

  private

  def report
    policy_scope(@current_company.reports).order(:created_at).last
  end
end
