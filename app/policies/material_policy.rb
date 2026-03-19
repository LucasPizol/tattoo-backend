class MaterialPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user.root? || user.can?(:see_others, Material) ? scope : scope.where(user_id: user.id)
    end
  end
end
