class Api::UserController < Api::BaseController
  def progress
    render json: {
      completedChapters: current_user.user_progress.completed.pluck(:chapter_id),
      completedLessons: current_user.lesson_progress.completed.pluck(:lesson_id),
      notes: current_user.user_notes.index_by(&:chapter_id).transform_values(&:content),
      highlights: current_user.user_highlights.group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
    }
  end
end
