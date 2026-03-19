class StockPolicy < ApplicationPolicy
  def see_others?
    user.root? || user.can?(:see_others, Stock)
  end
end
