class AddCurriculumToUserHighlights < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_highlights, :curriculum, null: true, foreign_key: true
    
    # Update existing user highlights to use the default curriculum
    default_curriculum = Curriculum.first
    if default_curriculum
      UserHighlight.update_all(curriculum_id: default_curriculum.id)
    end
    
    # Make curriculum_id non-nullable
    change_column_null :user_highlights, :curriculum_id, false
  end
end
