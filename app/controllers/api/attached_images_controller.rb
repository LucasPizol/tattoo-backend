class Api::AttachedImagesController < Api::ApplicationController
  def destroy
    ::ActiveStorage::Attachment.find(params[:id]).purge

    head :no_content
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end
end
