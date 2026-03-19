# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  description  :text             default(""), not null
#  due_date     :datetime
#  priority     :string           default("low"), not null
#  status       :string           default("open"), not null
#  title        :string           default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer          not null
#
# Indexes
#
#  index_notes_on_company_id    (company_id)
#  index_notes_on_completed_at  (completed_at)
#  index_notes_on_due_date      (due_date)
#  index_notes_on_priority      (priority)
#  index_notes_on_status        (status)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class Note < ApplicationRecord
  belongs_to :company

  STATUSES = %w[open in_progress completed]
  PRIORITIES = %w[low medium high]

  enum :status, STATUSES.index_by(&:itself)
  enum :priority, PRIORITIES.index_by(&:itself)

  validates :title, presence: true
  validates :description, presence: true
end
