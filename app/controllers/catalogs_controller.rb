class CatalogsController < ApplicationController
  def show
    @products_by_product_type = Product.all.group_by(&:product_type)

    respond_to do |format|
      format.pdf do
        render pdf: "catalogo_piercings",
               template: "catalogs/show",
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
