# frozen_string_literal: true

class CreateArticle < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.timestamps
    end
  end
end
