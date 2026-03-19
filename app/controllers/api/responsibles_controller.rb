class Api::ResponsiblesController < Api::ApplicationController
  before_action :set_client
  before_action :set_responsible, only: %i[ update destroy ]

  def create
    @responsible = @client.update_responsible!(responsible_params)

    render :show, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_error(@responsible)
  end

  def update
    if @responsible.update(responsible_params)
      render :show, status: :ok
    else
      render_error(@responsible)
    end
  end

  def destroy
    @responsible.destroy!

    head :no_content
  end

  private
    def set_responsible
      @responsible = @client.responsible
    end

    def set_client
      @client = @current_company.clients.find(params.expect(:client_id))
    end

    def responsible_params
      params.expect(responsible: [ :name, :email, :phone, :birth_date, :gender, :cpf, :rg ])
    end
end
