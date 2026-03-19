class AddColumnsToClient < ActiveRecord::Migration[8.0]
  def change
    change_table :clients, bulk: true do |t|
      t.string :cpf, index: { unique: true }
      t.string :rg
      t.date :birth_date
      t.string :gender
      t.string :marital_status

      t.boolean :diabetes, default: false
      t.boolean :epilepsy, default: false
      t.boolean :hemophilia, default: false
      t.boolean :vitiligo, default: false
      t.boolean :pacemaker, default: false
      t.boolean :high_blood_pressure, default: false
      t.boolean :low_blood_pressure, default: false
      t.boolean :disease_infectious_contagious, default: false
      t.boolean :healing_problems, default: false
      t.boolean :allergic_reactions, default: false
      t.boolean :hypersensitivity_to_chemicals, default: false
      t.boolean :keloid_proneness, default: false
      t.boolean :hipoglycemia, default: false
    end
  end
end
