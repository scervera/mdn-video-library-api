class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.string :title, null: false
      t.text :notes
      t.decimal :timestamp, precision: 10, scale: 2, null: false
      t.references :lesson, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Add indexes for better query performance
    add_index :bookmarks, [:user_id, :lesson_id]
    add_index :bookmarks, [:lesson_id, :timestamp]
    
    # Ensure unique constraint for user's bookmarks on the same lesson at the same timestamp
    add_index :bookmarks, [:user_id, :lesson_id, :timestamp], unique: true, name: 'index_bookmarks_on_user_lesson_timestamp_unique'
  end
end
