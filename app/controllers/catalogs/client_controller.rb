class Catalogs::ClientController < ApplicationController
  ITEMS_PER_ROW = 3
  ROWS_PER_PAGE = 3
  ITEMS_PER_PAGE = ITEMS_PER_ROW * ROWS_PER_PAGE # 9 items per page

  def show
    current_page = 2 # Page 1 is cover + summary

    @products = @current_company.products.with_attached_images
      .includes(:material).with_stock
      .where.not(product_type: nil)
      .order(:name)
      .group_by(&:product_type)
      .sort_by { |product_type, _products| ProductType.find(product_type)&.dig(:label).to_s.downcase }
      .map do |product_type, products|
        start_page = current_page
        # Calculate pages needed: ceil division for correct pagination
        pages_needed = (products.count.to_f / ITEMS_PER_PAGE).ceil
        pages_needed = 1 if pages_needed.zero?
        current_page += pages_needed
        [ product_type, { size: products.count, products: products, page: start_page } ]
      end

    respond_to do |format|
      format.pdf do
        render pdf: "catalogo_piercings_cliente",
               template: "catalogs/client/show",
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

      format.html do
        render "catalogs/client/show"
      end
    end
  end
end
