class Api::ProductTypesController < Api::ApplicationController
  def index
    render json: ProductType.as_array
  end
end
