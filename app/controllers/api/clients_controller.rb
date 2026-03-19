class Api::ClientsController < Api::ApplicationController
  include Pagination
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    authorize(Client, :index?)

    scope = policy_scope(@current_company.clients)

    @clients = scope
        .by_cpf(search_params[:cpf_matches])
        .birthday_month(search_params[:birthday_month_eq])
        .ransack(search_params.except(:cpf_matches, :birthday_month_eq))
        .result
        .includes(:responsible)
        .order(name: :asc)
        .paginate(page, per_page)
  end

  def show
    authorize(@client, :show?)

    render :show
  end

  def edit
    authorize(@client, :edit?)

    render :edit
  end

  def create
    authorize(Client, :create?)

    ActiveRecord::Base.transaction do
      @client = @current_company.clients.build(client_params.merge(user_id: current_user.id))

      if params[:addresses].present?
        address_params.each do |address|
          @client.addresses.build(address)
        end
      end

      @client.save!
      @client.update_responsible!(responsible_params)
    end

    render :show, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_error(@client, @client.address, @client.responsible)
  end

  def update
    authorize(@client, :update?)

    ActiveRecord::Base.transaction do
      @client.update_responsible!(responsible_params)
      @client.update!(client_params.merge(user_id: current_user.id))

      address_params.each do |address_param|
        if address_param[:id].present?
          @client.addresses.find(address_param[:id]).update!(address_param)
        else
          @client.addresses.create!(address_param)
        end
      end
    end

    render :show, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render_error(@client, @client.address, @client.responsible)
  end

  def destroy
    authorize(@client, :destroy?)

    @client.destroy!

    head :no_content
  end

  private
    def set_client
      @client = policy_scope(@current_company.clients).find(params.expect(:id))
    end

    def client_params
      params.expect(client: [ :name, :email, :phone, :birth_date, :indicated_by_id, :gender, :marital_status,
        :cpf, :rg, :diabetes, :epilepsy, :hemophilia, :vitiligo, :pacemaker, :high_blood_pressure, :low_blood_pressure,
        :disease_infectious_contagious, :healing_problems, :allergic_reactions, :hypersensitivity_to_chemicals,
        :keloid_proneness, :hipoglycemia, :instagram_profile, :observations
      ])
    end

    def address_params
      params.expect(addresses: [ [ :id, :street, :city, :state, :zipcode, :neighborhood, :number, :complement ] ])
    end

    def responsible_params
      params.fetch(:responsible, {}).permit(:name, :email, :phone, :birth_date, :gender, :cpf, :rg)
    end

    def search_params
      params.fetch(:q, {}).permit(:name_or_email_or_phone_cont, :cpf_matches, :birthday_month_eq, :indicated_by_id_eq)
    end
end
