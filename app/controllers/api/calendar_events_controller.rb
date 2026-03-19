class Api::CalendarEventsController < Api::ApplicationController
  before_action :set_calendar_event, only: %i[ show update destroy ]

  def index
    authorize(CalendarEvent, :index?)

    @calendar_events = policy_scope(@current_company.calendar_events).includes(:client).ransack(search_params).result.order(start_at: :asc)
  end

  def show
    authorize(@calendar_event, :show?)
  end

  def create
    authorize(CalendarEvent, :create?)

    @calendar_event = @current_company.calendar_events.build(calendar_event_params.except(:client_id).merge(user_id: current_user.id))
    @calendar_event.client = client if calendar_event_params[:client_id].present?

    if @calendar_event.save
      render :show, status: :created
    else
      render_error(@calendar_event)
    end
  end

  def update
    authorize(@calendar_event, :update?)

    @calendar_event.client = client if calendar_event_params[:client_id].present?

    if @calendar_event.update(calendar_event_params.except(:client_id))
      render :show, status: :ok
    else
      render_error(@calendar_event)
    end
  end

  def destroy
    authorize(@calendar_event, :destroy?)

    @calendar_event.destroy!
    head :no_content
  end

  private
    def set_calendar_event
      @calendar_event = policy_scope(@current_company.calendar_events).find(params[:id])
    end

    def calendar_event_params
      params.expect(calendar_event: [ :title, :description, :start_at, :end_at, :event_type, :status, :client_id, :client_name, :phone, :whatsapp_message, :send_whatsapp_message ])
    end

    def search_params
      params.fetch(:q, {}).permit(:title_cont, :description_cont, :start_at_gteq, :start_at_lteq, :end_at_gteq, :end_at_lteq)
    end

    def client
      policy_scope(@current_company.clients).find(calendar_event_params[:client_id])
    end
end
