class AddRequireResponsibleToProduct < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :require_responsible, :boolean, default: false, null: false
  end
end
