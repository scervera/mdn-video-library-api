class Api::Curricula::UserController < Api::BaseController
  before_action :set_curriculum

  def progress
    render json: {
      curriculum_id: @curriculum.id,
      curriculum_title: @curriculum.title,
      completedChapters: current_user.user_progress.where(curriculum: @curriculum).completed.pluck(:chapter_id),
      completedLessons: current_user.lesson_progress.joins(lesson: :chapter).where(chapters: { curriculum: @curriculum }).completed.pluck(:lesson_id),
      notes: current_user.user_notes.where(curriculum: @curriculum).index_by(&:chapter_id).transform_values(&:content),
      highlights: current_user.user_highlights.where(curriculum: @curriculum).group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
    }
  end

  private

  def set_curriculum
    @curriculum = Curriculum.find(params[:curricula_id])
  end
end
