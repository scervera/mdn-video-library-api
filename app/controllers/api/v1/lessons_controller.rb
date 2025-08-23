module Api
  module V1
    class LessonsController < BaseController
      before_action :set_lesson, only: [:show, :update, :destroy, :complete, :uncomplete]
      before_action :ensure_admin!, except: [:index, :show, :complete, :uncomplete]

      def index
        chapter = ::Chapter.find(params[:chapter_id])
        lessons = chapter.lessons.published.ordered
        render json: lessons.map { |lesson| lesson_with_progress(lesson) }
      end

      def show
        render json: lesson_with_progress(@lesson)
      end

      def create
        chapter = Current.tenant.chapters.find(params[:chapter_id])
        lesson = chapter.lessons.build(lesson_params)
        
        if lesson.save
          render json: lesson_with_progress(lesson), status: :created
        else
          render json: { errors: lesson.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @lesson.update(lesson_params)
          render json: lesson_with_progress(@lesson)
        else
          render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @lesson.destroy
          render json: { message: 'Lesson deleted successfully' }
        else
          render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def complete
        progress = current_user.lesson_progress.find_or_create_by(lesson: @lesson)
        progress.update(completed: true, completed_at: Time.current)
        render json: { message: 'Lesson completed' }
      end

      def uncomplete
        progress = current_user.lesson_progress.find_by(lesson: @lesson)
        
        if progress&.completed?
          progress.update(completed: false, completed_at: nil)
          render json: { success: true, message: 'Lesson marked as incomplete' }
        else
          render json: { success: false, error: 'Lesson was not previously completed' }, status: :unprocessable_entity
        end
      end

      private

      def set_lesson
        @lesson = Current.tenant.lessons.find(params[:id])
      end

      def lesson_params
        params.require(:lesson).permit(:title, :description, :content_type, :content, :media_url, :order_index, :published, :cloudflare_stream_id)
      end

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
          completed_at: progress&.completed_at,
          # Cloudflare Stream data
          cloudflare_stream_id: lesson.cloudflare_stream_id,
          cloudflare_stream_thumbnail: lesson.cloudflare_stream_thumbnail,
          cloudflare_stream_duration: lesson.cloudflare_stream_duration,
          cloudflare_stream_status: lesson.cloudflare_stream_status,
          formatted_duration: lesson.formatted_duration,
          video_ready: lesson.video_ready_for_playback?,
          video_player_data: lesson.video_player_data
        }
      end
    end
  end
end
