class ChangesIndexUniqueOnClient < ActiveRecord::Migration[8.1]
  def change
    remove_index :clients, :cpf

    add_index :clients, [ :cpf, :user_id ], unique: true, name: "index_clients_on_cpf_and_user_id"
  end
end
