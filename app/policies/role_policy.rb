class RolePolicy < ApplicationPolicy
  def available_permissions?
    user.root? || user.can?(:read, Permission)
  end
end
