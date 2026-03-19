class PaymentMethodPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user.root? || user.can?(:see_others, PaymentMethod) ? scope : scope.where(user_id: user.id)
    end
  end
end
