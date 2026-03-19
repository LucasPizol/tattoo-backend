class Api::CampaignsController < Api::ApplicationController
  before_action :set_campaign, only: [ :show, :update, :destroy ]

  def index
    authorize(Campaign, :index?)

    @campaigns = @current_company.campaigns
    @campaigns = @campaigns.active if params[:show_inactive].blank?

    render :index
  end

  def show
    authorize(@campaign, :show?)
  end

  def create
    authorize(Campaign, :create?)

    @campaign = @current_company.campaigns.build(campaign_params)

    if @campaign.save
      render :show, status: :created
    else
      render_error(@campaign)
    end
  end

  def update
    authorize(@campaign, :update?)

    if @campaign.update(campaign_params)
      render :show, status: :ok
    else
      render_error(@campaign)
    end
  end

  def destroy
    authorize(@campaign, :destroy?)

    @campaign.destroy!
    head :no_content
  end

  private

  def set_campaign
    @campaign = @current_company.campaigns.find(params.expect(:id))
  end

  def campaign_params
    params.expect(campaign: [ :name, :description, :indications_orders, :campaing_type, :active ])
  end
end
