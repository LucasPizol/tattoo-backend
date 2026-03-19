class CalendarEventNotifierJob < ApplicationJob
  include RandomTimeable

  sidekiq_options queue: :default

  def perform
    company = Company.find(Company::MAIN_COMPANY_ID)
    user = company.users.find(User::ACCOUNT_OWNER_ID)

    calendar_events = company.calendar_events.for_next_day.where(send_whatsapp_message: true, sent_whatsapp_message_at: nil).where.not(phone: nil)

    calendar_events.find_each.with_index do |calendar_event, index|
      Whatsapp::SendMessageJob.perform_in(random_minutes(index), company.id, calendar_event.phone.gsub(/\D/, ""), nil, calendar_event.whatsapp_message)
      calendar_event.update(sent_whatsapp_message_at: Time.current)
    end
  end
end
