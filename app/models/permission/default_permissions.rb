class Permission::DefaultPermissions
  ACTIONS = %w[read create update destroy].freeze

  PERMISSIONS = {
    clients: ACTIONS + %w[see_others],
    orders: ACTIONS + %w[see_others],
    calendar_events: ACTIONS + %w[see_others],
    products: ACTIONS + %w[see_others],
    materials: ACTIONS + %w[see_others],
    tags: ACTIONS + %w[see_others],
    payment_methods: ACTIONS + %w[see_others],
    notes: ACTIONS + %w[see_others],
    stock_movements: ACTIONS + %w[see_others],
    users: ACTIONS + %w[see_others],
    indications: ACTIONS,
    raffles: ACTIONS + %w[see_others],
    dashboard: ACTIONS + %w[see_others],
    instagram: ACTIONS + %w[see_others],
    roles: ACTIONS + %w[see_others],
    permissions: ACTIONS + %w[see_others],
  }

  def self.all
    PERMISSIONS.map { |resource, actions| actions.map { |action| "#{resource}.#{action}" } }.flatten
  end
end
