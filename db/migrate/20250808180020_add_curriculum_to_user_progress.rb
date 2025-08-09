class AddCurriculumToUserProgress < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_progresses, :curriculum, null: true, foreign_key: true
    
    # Update existing user progress records to use the default curriculum
    default_curriculum = Curriculum.first
    if default_curriculum
      UserProgress.update_all(curriculum_id: default_curriculum.id)
    end
    
    # Make curriculum_id non-nullable
    change_column_null :user_progresses, :curriculum_id, false
  end
end
