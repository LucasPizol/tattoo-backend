# == Schema Information
#
# Table name: clients
#
#  id                            :bigint           not null, primary key
#  allergic_reactions            :boolean          default(FALSE)
#  birth_date                    :date
#  cpf                           :string
#  diabetes                      :boolean          default(FALSE)
#  disease_infectious_contagious :boolean          default(FALSE)
#  email                         :string
#  encrypted_password            :string
#  epilepsy                      :boolean          default(FALSE)
#  gender                        :string
#  healing_problems              :boolean          default(FALSE)
#  hemophilia                    :boolean          default(FALSE)
#  high_blood_pressure           :boolean          default(FALSE)
#  hipoglycemia                  :boolean          default(FALSE)
#  hypersensitivity_to_chemicals :boolean          default(FALSE)
#  indicated_at                  :datetime
#  instagram_profile             :string
#  keloid_proneness              :boolean          default(FALSE)
#  low_blood_pressure            :boolean          default(FALSE)
#  marital_status                :string
#  name                          :string
#  observations                  :text
#  pacemaker                     :boolean          default(FALSE)
#  phone                         :string
#  rg                            :string
#  vitiligo                      :boolean          default(FALSE)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  company_id                    :integer          not null
#  indicated_by_id               :integer
#  user_id                       :bigint
#
# Indexes
#
#  index_clients_on_company_id       (company_id)
#  index_clients_on_cpf_and_user_id  (cpf,user_id) UNIQUE
#  index_clients_on_indicated_by_id  (indicated_by_id)
#  index_clients_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (indicated_by_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class Client < ApplicationRecord
  belongs_to :company
  belongs_to :user, optional: true
  has_many :addresses, dependent: :destroy
  has_one :responsible, dependent: :destroy
  has_one :user_client, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :order_products, dependent: :destroy, through: :orders
  has_many :products, dependent: :destroy, through: :order_products
  has_many :cart_products, dependent: :destroy
  belongs_to :indicated_by, class_name: "Client", optional: true
  has_many :indicated_clients, class_name: "Client", foreign_key: :indicated_by_id

  HEALTH_CONDITIONS = [
    :diabetes,
    :epilepsy,
    :hemophilia,
    :vitiligo,
    :pacemaker,
    :high_blood_pressure,
    :low_blood_pressure,
    :disease_infectious_contagious,
    :healing_problems,
    :allergic_reactions,
    :hypersensitivity_to_chemicals,
    :keloid_proneness,
    :hipoglycemia
  ]

  validates :name, presence: true
  validates :birth_date, comparison: { less_than: Date.today }, allow_blank: true

  before_save :set_indicated_at, if: -> { indicated_by_id.present? }

  normalizes :email, with: ->(value) do
    return nil if value.blank?

    value.downcase.strip
  end
  normalizes :phone, with: ->(value) do
    return nil if value.blank?

    value.gsub(/\D/, "")
  end
  normalizes :birth_date, with: ->(value) do
    return nil if value.blank?

    value.to_date
  end
  normalizes :name, with: ->(value) do
    return nil if value.blank?

    value.strip
  end
  normalizes :cpf, with: ->(value) do
    return nil if value.blank?

    value.gsub(/\D/, "")
  end
  validates :cpf, uniqueness: { scope: :user_id }, if: -> { cpf.present? }

  scope :by_cpf, ->(cpf) { where("cpf LIKE ?", "%#{cpf}%") if cpf.present? }
  scope :birthday_today, -> {
    where("EXTRACT(MONTH FROM birth_date) = ? AND EXTRACT(DAY FROM birth_date) = ?", Time.current.month, Time.current.day)
  }

  scope :birthday_month, ->(month) {
    if month.present?
      where("EXTRACT(MONTH FROM birth_date) = ?", month.to_i)
    end
  }

  ransacker :total_value do
    Arel.sql("total_value")
  end

  ransacker :total_orders do
    Arel.sql("total_orders")
  end

  ransacker :total_indications do
    Arel.sql("total_indications")
  end

  scope :with_report, lambda {
    left_joins(:orders)
      .select("
        clients.id,
        clients.name,
        clients.email,
        clients.phone,
        clients.indicated_at,
        COUNT(orders.id) FILTER (WHERE orders.paid_at > clients.indicated_at) as total_orders,
        (SUM(orders.product_values_subcents) FILTER (WHERE orders.paid_at > clients.indicated_at)) - SUM(orders.cost_value_subcents) FILTER (WHERE orders.paid_at > clients.indicated_at) / 100 as total_value
      ")
      .group(:id)
      .distinct
  }

  scope :with_report_indications, lambda {
    joins(:indicated_clients)
      .left_joins(indicated_clients: :orders)
      .where.not(indicated_clients: { indicated_at: nil })
      .group(:id)
      .select("
        clients.id,
        clients.name,
        clients.email,
        clients.phone,
        COUNT(orders.id) FILTER (WHERE orders.paid_at > indicated_clients.indicated_at) as total_orders,
        COUNT(DISTINCT indicated_clients.id) as total_indications,
        COALESCE(SUM(orders.product_values_subcents) FILTER (WHERE orders.paid_at > indicated_clients.indicated_at) - SUM(orders.cost_value_subcents) FILTER (WHERE orders.paid_at > indicated_clients.indicated_at) / 100, 0) as total_value,
        COUNT(DISTINCT indicated_clients.id) FILTER (WHERE orders.paid_at > indicated_clients.indicated_at) as total_indications_who_bought
      ")
      .distinct
  }

  def age
    return 999 if birth_date.blank?
    (Date.today - birth_date).to_i / 365
  end

  def lower_age?
    age < 18
  end

  def first_name
    name.split(" ").first.strip.capitalize
  end

  def has_health_conditions?
    HEALTH_CONDITIONS.any? { |condition| send(condition) }
  end

  def birth_month?
    birth_date.present? && birth_date.month == Date.today.month
  end

  def address
    addresses.first
  end

  def set_indicated_at
    self.indicated_at = Time.current
  end

  def update_responsible!(responsible_params)
    return if responsible_params.blank?

    if responsible.present?
      responsible.update(responsible_params)
    else
      self.create_responsible!(responsible_params)
    end
  end

  def cart_products_total
    Money.new(self.cart_products.sum("value_subcents * quantity"), :brl)
  end

  def clear_cart(product_ids)
    if product_ids.present?
      self.cart_products.where(product_id: product_ids).destroy_all
    else
      self.cart_products.destroy_all
    end
  end
end
