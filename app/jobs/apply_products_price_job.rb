class ApplyProductsPriceJob < ApplicationJob
  attr_reader :company

  # sidekiq_options lock: :until_expired, queue: :default

  def perform(company_id)
    @company = Company.find(company_id)
    company_config = company.company_config

    ActiveRecord::Base.transaction do
      company.products.find_each do |product|
        product.value = company_config.calculate_product_value(product.value)
        product.save!(validate: false)
      end
      company_config.update!(product_percentage_variation: 0)
    rescue StandardError => e
      raise e
    end

    Rails.cache.delete([ "company_config", company_id ])
    broadcast_to_company("success", "Preços aplicados com sucesso")
  rescue StandardError => e
    puts "Error applying products price: #{e.message}"
    broadcast_to_company("error", e.message)
  end

  private

  def broadcast_to_company(status, message)
    CompanyChannel.broadcast_to(@company, {
      type: "products_price_applied",
      data: {
        status: status,
        message: message
      }
    })
  end
end
