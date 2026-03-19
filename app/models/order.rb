# == Schema Information
#
# Table name: orders
#
#  id                                     :bigint           not null, primary key
#  applied_birth_date_discount_percentage :integer          default(0), not null
#  comissions_value_cents                 :integer          default(0), not null
#  comissions_value_currency              :string           default("BRL"), not null
#  cost_value_currency                    :string           default("BRL")
#  cost_value_subcents                    :integer          default(0), not null
#  created_by                             :integer          default("user")
#  idempotency_key                        :string
#  local_pickup                           :boolean          default(FALSE)
#  paid_at                                :datetime
#  product_values_currency                :string           default("BRL")
#  product_values_subcents                :integer          default(0), not null
#  status                                 :integer          default("pending"), not null
#  taxes_values_currency                  :string           default("BRL")
#  taxes_values_subcents                  :integer          default(0), not null
#  values_divided                         :boolean          default(FALSE), not null
#  whatsapp_notified_at                   :datetime
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  address_id                             :integer
#  client_id                              :integer
#  company_id                             :integer
#  external_id                            :integer
#  user_id                                :integer
#
# Indexes
#
#  index_orders_on_address_id  (address_id)
#  index_orders_on_client_id   (client_id)
#  index_orders_on_company_id  (company_id)
#  index_orders_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  TAXES_DEADLINE_DATE = Date.new(2025, 12, 23)

  belongs_to :client, optional: true
  belongs_to :company, optional: true
  belongs_to :address, optional: true
  belongs_to :user, optional: true
  has_one :shipping, dependent: :destroy

  has_many_attached :images
  has_many :order_products, dependent: :destroy
  has_many :stocks, through: :order_products
  has_many :products, through: :stocks
  has_many :sale_messages, dependent: :destroy
  has_many :comissions, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :shipping_estimations, dependent: :destroy
  has_many :order_payment_methods, dependent: :destroy
  has_many :payment_methods, through: :order_payment_methods

  monetize :product_values_subcents, as: :product_value
  monetize :cost_value_subcents, as: :cost_value
  monetize :taxes_values_subcents, as: :taxes_value
  monetize :comissions_value_cents, as: :comissions_value

  enum :status, {
    pending: 0,
    paid: 1,
    canceled: 2,
    reopened: 3,
    waiting_for_payment: 4,
    processing: 5,
  }

  enum :created_by, { user: 0, client: 1 }

  validates :product_values_subcents, presence: true, if: :is_finishing?
  validates :product_values_currency, presence: true, if: :is_finishing?
  validates :client, presence: true, if: -> { is_finishing? && created_by == :user }
  validate :disable_edit_if_paid, if: -> { status_was == "paid" }

  before_save :require_responsible, if: :require_responsible?
  before_save :set_place, if: -> { will_save_change_to_local_pickup? || will_save_change_to_address_id? }

  scope :current_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }

  def total_value
    return product_value - birth_date_discount_value if paid_at.present? && paid_at < TAXES_DEADLINE_DATE
    product_value - birth_date_discount_value + (created_by == :user ? -taxes_value : taxes_value)
  end

  def total_value_with_comissions
    total_value
  end

  def pending?
    %w[pending processing waiting_for_payment reopened].include?(self.status.to_s)
  end

  def created_by_user?
    created_by == "user"
  end

  def created_by_client?
    created_by == "client"
  end

  def reopen
    Order.transaction do
      self.status = :reopened
      self.stock_movements.destroy_all
      self.paid_at = nil
      self.save!(validate: false)
      self.calendar_events.destroy_all
    end
  end

  def send_confirmation_message
    return if self.whatsapp_notified_at.present?

    Whatsapp::SendMessageJob.perform_async(company_id, self.client.phone, Whatsapp::Templates::OrderConfirmation.build)
    self.update_column(:whatsapp_notified_at, Time.current)
  end

  def send_email_confirmation_message
    OrderMailer.order_received(self).deliver_later
  end

  def recalculate_values
    result = self.order_products
      .select(
        "COALESCE(SUM(value_subcents * quantity), 0) AS total_value_subcents, " \
        "COALESCE(SUM(cost_value_subcents * quantity), 0) AS total_cost_value_subcents"
      )
      .take

    applied_discount_percentage = self.applied_birth_date_discount_percentage || 0

    self.product_values_subcents = result.total_value_subcents
    self.product_values_subcents = self.product_values_subcents * (applied_discount_percentage.zero? ? 1 : (1 - applied_discount_percentage / 100))

    self.comissions.each do |comission|
      comission.calculate_value
      comission.save
    end

    self.cost_value_subcents = result.total_cost_value_subcents
  end

  def apply_birth_date_discount
    return unless self.can_apply_birth_date_discount?

    self.applied_birth_date_discount_percentage = self.company.company_config&.birth_date_discount_percentage || 0
    self.calculate_comissions
    self.save!
  end

  def remove_birth_date_discount
    return unless self.has_applied_birth_date_discount?

    self.applied_birth_date_discount_percentage = 0
    self.calculate_comissions
    self.save!
  end

  def can_apply_birth_date_discount?
    self.client&.birth_month? && self.company.company_config&.birth_date_discount_percentage&.positive?
  end

  def has_applied_birth_date_discount?
    self.applied_birth_date_discount_percentage.positive?
  end

  def birth_date_discount_value
    Money.new(self.product_values_subcents * self.applied_birth_date_discount_percentage / 100, :brl)
  end

  def is_parts_synchronized?
    true
  end

  def calculate_comissions
    self.comissions_value = self.comissions.sum(&:value)
  end

  private

  def set_place
    if self.local_pickup?
      self.address_id = nil
    elsif self.address_id.present?
      self.local_pickup = false
    end
  end

  def has_paid?
    saved_change_to_status? && paid?
  end

  def is_finishing?
    self.status_changed? && paid?
  end

  def disable_edit_if_paid
    errors.add(:base, "Não é possível editar um pedido pago")
    throw :abort
  end

  def create_stock_movements
    self.order_products.each do |order_product|
      StockMovement.create!(stock: order_product.stock, quantity: order_product.quantity.abs, value: order_product.value, movement_type: order_product.quantity.positive? ? :out : :in, company: self.company, order: self)
    end
  end

  def require_responsible
    if self.client.lower_age? && self.client.responsible.blank?
      self.errors.add(:responsible, "deve ter pelo menos um responsável com idade superior a 18 anos")
      throw :abort
    end
  end

  def require_responsible?
    self.status_changed? && self.products.any?(&:require_responsible?) && paid?
  end
end
