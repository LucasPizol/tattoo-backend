class Api::UserComissionsController < Api::ApplicationController
  before_action :set_order

  def create
    user_comissions = @order.user_comissions.index_by(&:user_id)

    user_comissions_params.each do |user_comission_params|
      user_comission = user_comissions[user_comission_params[:user_id]] || @order.user_comissions.build(user_id: user_comission_params[:user_id])
      user_comission.update!(
        comission_value: user_comission_params[:comission_value],
        received_value: user_comission_params[:received_value],
        payment_method_id: user_comission_params[:payment_method_id],
        order: @order
      )
    end

    @order.save

    head :ok
  end

  private
    def user_comissions_params
      params.expect(user_comissions: [ [ :comission_value, :received_value, :order_id, :payment_method_id, :user_id ] ])
    end

    def set_order
      order_ids = user_comissions_params.map { it[:order_id] }

      if order_ids.uniq.count == 1
        @order = @current_company.orders.find(order_ids.first)
      else
        raise "All user comissions must be for the same order"
      end
    end
end
