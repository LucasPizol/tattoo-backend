class Api::NotificationsController < Api::ApplicationController
  def index
    @calendar_events_today = @current_company.calendar_events
                                          .where("start_at >= ?", Time.current.beginning_of_day)
                                          .where("start_at < ?", Time.current.end_of_day)
                                          .count

    @notes_today = @current_company.notes
                                .where("due_date >= ?", Time.current.beginning_of_day)
                                .where("due_date < ?", Time.current.end_of_day)
                                .count

    render json: {
      calendarEventsToday: @calendar_events_today,
      notesToday: @notes_today
    }
  end
end
