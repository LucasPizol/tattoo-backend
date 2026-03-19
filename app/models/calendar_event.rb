# == Schema Information
#
# Table name: calendar_events
#
#  id                       :bigint           not null, primary key
#  client_name              :string
#  description              :text
#  end_at                   :datetime         not null
#  event_type               :string           not null
#  phone                    :string
#  reschedule_count         :integer          default(0), not null
#  send_whatsapp_message    :boolean          default(FALSE), not null
#  sent_whatsapp_message_at :datetime
#  start_at                 :datetime         not null
#  status                   :string           default("pending"), not null
#  title                    :string           not null
#  whatsapp_message         :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  client_id                :integer
#  company_id               :integer          not null
#  order_id                 :bigint
#  user_id                  :bigint
#
# Indexes
#
#  index_calendar_events_on_client_id   (client_id)
#  index_calendar_events_on_company_id  (company_id)
#  index_calendar_events_on_order_id    (order_id)
#  index_calendar_events_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (user_id => users.id)
#
class CalendarEvent < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :company
  belongs_to :order, optional: true

  EVENT_TYPES = %w[piercing sell repair]
  STATUSES = %w[pending completed canceled]

  COLORS = {
    piercing: "#3b82f6",
    sell: "#10b981",
    repair: "#06b6d4"
  }

  enum :event_type, EVENT_TYPES.index_by(&:itself)
  enum :status, STATUSES.index_by(&:itself)

  validates :event_type, presence: true
  # validates :start_at, presence: true, comparison: { less_than_or_equal_to: :end_at, greater_than: Time.current }
  # validates :end_at, presence: true, comparison: { greater_than_or_equal_to: :start_at }
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :reschedule_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :check_disponibility, if: -> { (will_save_change_to_start_at? || will_save_change_to_end_at?) && !order_id.present? }

  after_update :reschedule, if: -> { saved_change_to_start_at? }

  scope :for_next_day, -> {
    tomorrow = Time.current.tomorrow.beginning_of_day
    tomorrow_end = tomorrow.end_of_day

    where("start_at >= ? AND start_at <= ?", tomorrow, tomorrow_end)
  }


  def reschedule
    self.reschedule_count += 1
  end

  def display_title
    return title if client_name.blank?
    "#{client_name} - #{title}"
  end

  def check_disponibility
    has_overlap = self.company
                      .calendar_events
                      .where("end_at > ?", self.start_at)
                      .where("start_at < ?", self.end_at)
                      .where.not(id: self.id)
                      .exists?

    if has_overlap
      # self.errors.add(:base, "Já existe um evento no mesmo horário")
    end
  end
end
