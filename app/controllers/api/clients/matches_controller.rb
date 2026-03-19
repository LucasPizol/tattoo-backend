class Api::Clients::MatchesController < Api::ApplicationController
  def index
    @client = @current_company.clients.by_cpf(search_params[:cpf_matches]).last

    if @client.present?
      render "api/clients/show", client: @client
    else
      render :no_content, status: :no_content
    end
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:name_cont, :email_cont, :phone_cont, :cpf_matches)
  end
end
