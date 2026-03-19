# frozen_string_literal: true

class CreateUserConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :user_configs do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.integer :birth_date_discount_percentage, null: false, default: 0

      t.timestamps
    end
  end
end
