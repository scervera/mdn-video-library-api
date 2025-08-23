class MakeChapterIdNullableInUserNotes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_notes, :chapter_id, true
  end
end
