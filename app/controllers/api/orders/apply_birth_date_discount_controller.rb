class Api::Orders::ApplyBirthDateDiscountController < Api::ApplicationController
  before_action :set_order

  def update
    return head :bad_request unless @order.can_apply_birth_date_discount?

    if @order.has_applied_birth_date_discount?
      @order.remove_birth_date_discount
    else
      @order.apply_birth_date_discount
    end

    head :no_content
  end

  private

  def set_order
    @order = @current_company.orders.find(params.expect(:order_id))
  end
end
