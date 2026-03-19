class Api::Clients::IndicationsController < Api::ApplicationController
  def index
    @client = @current_company.clients.find(params.expect(:client_id))
    @indications = @client.indicated_clients.with_report

    render :index
  end
end
