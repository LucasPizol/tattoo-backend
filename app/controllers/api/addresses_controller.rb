class Api::AddressesController < Api::ApplicationController
  before_action :set_address, only: %i[ destroy ]

  def destroy
    @address.destroy!

    head :no_content
  end

  private

  def set_address
    @address = @current_company.addresses.find(params.expect(:id))
  end
end
