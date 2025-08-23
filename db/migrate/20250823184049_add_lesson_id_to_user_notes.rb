class AddLessonIdToUserNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :user_notes, :lesson, null: true, foreign_key: true
    add_index :user_notes, [:user_id, :lesson_id], unique: true, where: "lesson_id IS NOT NULL"
  end
end
