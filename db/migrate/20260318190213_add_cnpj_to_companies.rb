class AddCnpjToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :cnpj, :string
    add_index :companies, :cnpj, unique: true
  end
end
