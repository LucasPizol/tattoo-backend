class AddColorToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :color, :string
    add_column :users, :text_color, :string
  end
end
