class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :time_zone, null: false, default: "UTC"
      t.timestamps
    end
  end
end
