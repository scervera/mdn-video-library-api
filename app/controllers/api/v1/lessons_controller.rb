module Api
  module V1
    class LessonsController < BaseController
      def index
        chapter = Chapter.find(params[:chapter_id])
        lessons = chapter.lessons.published.ordered
        render json: lessons.map { |lesson| lesson_with_progress(lesson) }
      end

      def show
        lesson = Lesson.find(params[:id])
        render json: lesson_with_progress(lesson)
      end

      def complete
        lesson = Lesson.find(params[:id])
        progress = current_user.lesson_progress.find_or_create_by(lesson: lesson)
        progress.update(completed: true, completed_at: Time.current)
        render json: { message: 'Lesson completed' }
      end

      private

      def lesson_with_progress(lesson)
        progress = current_user.lesson_progress.find_by(lesson: lesson)
        {
          id: lesson.id,
          title: lesson.title,
          description: lesson.description,
          content_type: lesson.content_type,
          content: lesson.content,
          media_url: lesson.media_url,
          order_index: lesson.order_index,
          published: lesson.published,
          chapter_id: lesson.chapter_id,
          completed: progress&.completed || false,
          completed_at: progress&.completed_at
        }
      end
    end
  end
end
