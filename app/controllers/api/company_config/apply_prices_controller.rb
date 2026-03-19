# frozen_string_literal: true

class Api::CompanyConfig::ApplyPricesController < Api::ApplicationController
  def create
    ApplyProductsPriceJob.perform_async(@current_company.id)
    head :no_content
  end
end
