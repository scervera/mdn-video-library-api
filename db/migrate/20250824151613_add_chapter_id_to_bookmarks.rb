class AddChapterIdToBookmarks < ActiveRecord::Migration[8.0]
  def change
    # Add chapter_id column as nullable first
    add_reference :bookmarks, :chapter, null: true, foreign_key: true
    
    # Populate existing bookmarks with chapter_id from their lessons
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE bookmarks 
          SET chapter_id = lessons.chapter_id 
          FROM lessons 
          WHERE bookmarks.lesson_id = lessons.id
        SQL
      end
    end
  end
end
