# frozen_string_literal: true

class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :time_zone, null: false, default: "UTC"
      t.timestamps
    end
  end
end
