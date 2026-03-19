class AddObservationsToClient < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :observations, :text
  end
end
