class Api::CompanyConfigsController < Api::ApplicationController
  before_action :set_company_config

  def update
    if @company_config.update(company_config_params)
      clear_company_config_cache
      cache_company_config

      head :no_content
    else
      render_error(@company_config)
    end
  end

  private

  def set_company_config
    @company_config = @current_company.company_config || @current_company.build_company_config
  end

  def company_config_params
    params.expect(company_config: [ :birth_date_discount_percentage, :product_percentage_variation ])
  end
end
