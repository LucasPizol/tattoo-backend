class Catalogs::InternalController < ApplicationController
  def show
    @products = @current_user.products.with_attached_images.includes(:material, :tags).order(:name)

    respond_to do |format|
      format.pdf do
        render pdf: "catalogo_piercings_interno",
               template: "catalogs/internal/show",
               layout: "pdf",
               formats: [ :html ],
               page_size: "A4",
               local_file_access: true,
               margin: {
                top: "0mm",
                bottom: "8mm",
                left: "0mm",
                right: "0mm"
               },
               footer: {
                html: {
                  template: "shared/_footer",
                  formats: [ :html ],
                  layout: nil
                }
              }
      end
    end
  end
end
