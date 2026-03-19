class AddInstagramProfileToClient < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :instagram_profile, :string
  end
end
