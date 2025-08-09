class AddCurriculumToUserNotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_notes, :curriculum, null: true, foreign_key: true
    
    # Update existing user notes to use the default curriculum
    default_curriculum = Curriculum.first
    if default_curriculum
      UserNote.update_all(curriculum_id: default_curriculum.id)
    end
    
    # Make curriculum_id non-nullable
    change_column_null :user_notes, :curriculum_id, false
  end
end
