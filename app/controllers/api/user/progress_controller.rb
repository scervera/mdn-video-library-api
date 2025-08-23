class Api::User::ProgressController < Api::BaseController
  def index
    # Get lesson-level notes
    lesson_notes = current_user.user_notes
      .where.not(lesson_id: nil)
      .index_by(&:lesson_id)
      .transform_values(&:content)
    
    # Get chapter-level notes (for backward compatibility)
    chapter_notes = current_user.user_notes
      .where.not(chapter_id: nil)
      .index_by(&:chapter_id)
      .transform_values(&:content)
    
    render json: {
      completedChapters: current_user.user_progress.completed.pluck(:chapter_id),
      completedLessons: current_user.lesson_progress.completed.pluck(:lesson_id),
      notes: lesson_notes, # Return lesson-level notes as primary
      chapterNotes: chapter_notes, # Keep chapter notes for backward compatibility
      highlights: current_user.user_highlights.group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
    }
  end

  def curriculum_progress
    curriculum = Curriculum.find(params[:curriculum_id])
    
    # Get lesson-level notes for this curriculum
    lesson_notes = current_user.user_notes
      .joins(lesson: :chapter)
      .where(chapters: { curriculum: curriculum })
      .where.not(lesson_id: nil)
      .index_by(&:lesson_id)
      .transform_values(&:content)
    
    # Get chapter-level notes for this curriculum (for backward compatibility)
    chapter_notes = current_user.user_notes
      .where(curriculum: curriculum)
      .where.not(chapter_id: nil)
      .index_by(&:chapter_id)
      .transform_values(&:content)
    
    render json: {
      curriculum_id: curriculum.id,
      curriculum_title: curriculum.title,
      completedChapters: current_user.user_progress.where(curriculum: curriculum).completed.pluck(:chapter_id),
      completedLessons: current_user.lesson_progress.joins(lesson: :chapter).where(chapters: { curriculum: curriculum }).completed.pluck(:lesson_id),
      notes: lesson_notes, # Return lesson-level notes as primary
      chapterNotes: chapter_notes, # Keep chapter notes for backward compatibility
      highlights: current_user.user_highlights.where(curriculum: curriculum).group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
    }
  end
end
