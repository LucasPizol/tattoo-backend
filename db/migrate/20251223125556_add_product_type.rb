class AddProductType < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.string :product_type
    end

    Product.where(product_type: nil).each do |product|
      if product.name.downcase.include?("argola") || product.name.downcase.include?("argala")
        product.update(product_type: "ring")
      elsif product.name.downcase.include?("ferradura")
        product.update(product_type: "ferradura")
      elsif product.name.downcase.include?("captive")
        product.update(product_type: "captive")
      elsif product.name.downcase.include?("banana")
        product.update(product_type: "banana_bell")
      elsif product.name.downcase.include?("barbell") || product.name.downcase.include?("barbel") || product.name.downcase.include?("mamilo") || product.name.downcase.include?("transversal")
        product.update(product_type: "barbell")
      elsif product.name.downcase.include?("clicker")
        product.update(product_type: "clicker")
      elsif product.name.downcase.include?("microdermal")
        product.update(product_type: "microdermal")
      elsif product.name.downcase.include?("twister")
        product.update(product_type: "twister")
      elsif product.name.downcase.include?("labret")
        product.update(product_type: "labret")
      elsif product.name.downcase.include?("nostril")
        product.update(product_type: "nostril")
      elsif product.name.downcase.include?("brinco")
        product.update(product_type: "brinco")
      end
    end
  end
end
