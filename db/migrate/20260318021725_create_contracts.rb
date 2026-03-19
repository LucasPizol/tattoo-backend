class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.text :content, null: false
      t.integer :version, default: 1, null: false
      t.datetime :signed_at
      t.string :signer_ip
      t.string :signer_user_agent

      t.timestamps
    end
  end
end
