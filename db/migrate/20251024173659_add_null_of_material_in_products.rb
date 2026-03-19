# frozen_string_literal: true

class AddNullOfMaterialInProducts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :products, :material_id, true
  end
end
