class CreateUserHighlights < ActiveRecord::Migration[7.1]
  def change
    create_table :user_highlights do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chapter, null: false, foreign_key: true
      t.string :highlighted_text

      t.timestamps
    end
  end
end
