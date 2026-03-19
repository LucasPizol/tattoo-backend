class RemoveNotNullOnResponsibleEmail < ActiveRecord::Migration[8.0]
  def up
    change_column_null :responsibles, :email, true
  end

  def down
    change_column_null :responsibles, :email, false
  end
end
