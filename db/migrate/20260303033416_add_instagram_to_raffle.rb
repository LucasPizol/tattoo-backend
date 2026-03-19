class AddInstagramToRaffle < ActiveRecord::Migration[8.1]
  def change
    add_reference :raffles, :instagram_post, null: true, foreign_key: true
  end
end
