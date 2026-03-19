class Api::NotesController < Api::ApplicationController
  before_action :set_note, only: [ :show, :update, :destroy ]

  def index
    authorize(Note, :index?)

    @notes = current_company.notes
                         .ransack(search_params)
                         .result
                         .order(
                            Arel.sql(
                              "CASE status WHEN 'open' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'completed' THEN 3 END ASC,
                               CASE priority WHEN 'low' THEN 1 WHEN 'medium' THEN 2 WHEN 'high' THEN 3 END DESC,
                               due_date ASC"
                          ))
  end

  def show
    authorize(@note, :show?)

    render :show
  end

  def create
    authorize(Note, :create?)

    @note = current_company.notes.build(note_params)

    if @note.save
      render :show, status: :created
    else
      render_error(@note)
    end
  end

  def update
    authorize(@note, :update?)

    @note.update(note_params)

    if @note.save
      render :show, status: :ok
    else
      render_error(@note)
    end
  end

  def destroy
    authorize(@note, :destroy?)

    @note.destroy

    head :no_content
  end

  private

  def set_note
    @note = current_company.notes.find(params[:id])
  end

  def note_params
    params.expect(note: [ :title, :description, :status, :priority, :due_date ])
  end

  def search_params
    params.fetch(:q, {}).permit(:due_date_gteq, :due_date_lteq, :title_or_description_cont, status_in: [], priority_in: [])
  end
end
