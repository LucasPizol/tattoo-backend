class Api::Instagram::AccountsController < Api::ApplicationController
  def index
    @instagram_accounts = @current_company.company_instagram_accounts
    render :index
  end

  def destroy
    @instagram_account = @current_company.company_instagram_accounts.find(params[:id])
    @instagram_account.destroy
    head :no_content
  end
end
