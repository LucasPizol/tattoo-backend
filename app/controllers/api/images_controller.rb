class Api::ImagesController < Api::ApplicationController
  before_action :set_image

  def destroy
    @image.purge

    head :no_content
  end

  private
    def set_image
      @image = @current_company.images_attachments.find(params.expect(:id))
    end
end
