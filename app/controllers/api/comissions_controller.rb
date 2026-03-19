class Api::ComissionsController < Api::ApplicationController
  before_action :set_order
  before_action :set_comission, only: %i[ update destroy ]

  def create
    comission = @order.comissions.build(comission_params)

    if comission.save
      head :created
    else
      render_error(comission)
    end
  end

  def update
    if @comission.update(comission_params)
      head :no_content
    else
      render_error(@comission)
    end
  end

  def destroy
    @comission.destroy!

    head :no_content
  end

  private

  def comission_params
    params.expect(comission: [ :name, :percentage, :value ])
  end

  def set_order
    @order = @current_company.orders.find(params.expect(:order_id))
  end

  def set_comission
    @comission = @order.comissions.find(params.expect(:id))
  end
end
