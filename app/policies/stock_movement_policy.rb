class StockMovementPolicy < ApplicationPolicy
  # O controller usa can?(:delete, StockMovement) — a string no banco é "stock_movements.delete"
  def destroy?
    user.root? || user.can?(:delete, StockMovement)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.root? || user.can?(:see_others, StockMovement)
        scope
      else
        scope.joins(:stock).where(stock: { user_id: user.id })
      end
    end
  end
end
