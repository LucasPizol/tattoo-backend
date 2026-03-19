class Roles::SeedAdminRoleService
  ADMIN_ROLE_NAME = "Administrador".freeze

  def initialize(company)
    @company = company
  end

  def call
    ActiveRecord::Base.transaction do
      role = @company.roles.find_or_create_by!(name: ADMIN_ROLE_NAME)

      existing = role.permissions.pluck(:name).to_set
      missing = Permission::DefaultPermissions.all.reject { |name| existing.include?(name) }

      role.permissions.create!(missing.map { |name| { name: name } }) if missing.any?

      role
    end
  end
end
