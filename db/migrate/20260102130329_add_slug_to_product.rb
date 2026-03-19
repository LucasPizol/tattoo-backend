class AddSlugToProduct < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.string :slug
      t.index :slug, unique: true
    end

    Product.all.each do |product|
      other_products = Product.where(slug: product.name.parameterize)

      if other_products.any?
        data = other_products.map do |other_product|
          other_product.slug = "#{other_product.name.parameterize}-#{other_product.id}"
          other_product
        end

        Product.insert_all(data.map { |other_product| other_product.attributes.except("id") })
        product.slug = "#{product.name.parameterize}-#{product.id}"
        product.save!(validate: false)

        next
      end

      product.slug = product.name.parameterize
      product.save!(validate: false)
    end

    change_column_null :products, :slug, false
  end
end
