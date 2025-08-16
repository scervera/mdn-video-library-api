module Api
  module V1
    module User
      class ProgressController < BaseController
        def index
          render json: {
            completedChapters: current_user.user_progress.completed.pluck(:chapter_id),
            completedLessons: current_user.lesson_progress.completed.pluck(:lesson_id),
            notes: current_user.user_notes.index_by(&:chapter_id).transform_values(&:content),
            highlights: current_user.user_highlights.group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
          }
        end

        def curriculum_progress
          curriculum = Curriculum.find(params[:curriculum_id])
          render json: {
            curriculum_id: curriculum.id,
            curriculum_title: curriculum.title,
            completedChapters: current_user.user_progress.where(curriculum: curriculum).completed.pluck(:chapter_id),
            completedLessons: current_user.lesson_progress.joins(lesson: :chapter).where(chapters: { curriculum: curriculum }).completed.pluck(:lesson_id),
            notes: current_user.user_notes.where(curriculum: curriculum).index_by(&:chapter_id).transform_values(&:content),
            highlights: current_user.user_highlights.where(curriculum: curriculum).group_by(&:chapter_id).transform_values { |highlights| highlights.pluck(:highlighted_text) }
          }
        end
      end
    end
  end
end
