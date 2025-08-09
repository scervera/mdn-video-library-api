class AddCurriculumToChapters < ActiveRecord::Migration[7.1]
  def change
    add_reference :chapters, :curriculum, null: true, foreign_key: true
    
    # Create a default curriculum
    default_curriculum = Curriculum.create!(
      title: "Christian Foundation",
      description: "A comprehensive curriculum covering the fundamentals of Christian faith and practice.",
      published: true,
      order_index: 1
    )
    
    # Update existing chapters to use the default curriculum
    Chapter.update_all(curriculum_id: default_curriculum.id)
    
    # Make curriculum_id non-nullable
    change_column_null :chapters, :curriculum_id, false
  end
end
