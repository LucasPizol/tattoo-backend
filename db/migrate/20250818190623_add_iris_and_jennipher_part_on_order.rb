class AddIrisAndJennipherPartOnOrder < ActiveRecord::Migration[8.0]
  def change
    change_table :orders, bulk: true do |t|
      t.monetize :iris_part
      t.monetize :jennipher_part
    end
  end
end
