class ProductPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user.root? || user.can?(:see_others, Product) ? scope : scope.where(user_id: user.id)
    end
  end
end
