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
        params.require(:lesson).permit(:title, :description, :order_index, :published)
      end

      def lesson_with_progress(lesson)
        progress = current_user.lesson_progress.find_by(lesson: lesson)
        {
          id: lesson.id,
          title: lesson.title,
          description: lesson.description,
          order_index: lesson.order_index,
          published: lesson.published,
          chapter_id: lesson.chapter_id,
          completed: progress&.completed || false,
          completed_at: progress&.completed_at,
          # Module information
          module_count: lesson.module_count,
          has_video_modules: lesson.has_video_modules?,
          has_text_modules: lesson.has_text_modules?,
          has_assessment_modules: lesson.has_assessment_modules?,
          # Include modules if requested
          modules: include_modules? ? lesson.lesson_modules.map { |module_item| lesson_module_response(module_item) } : nil
        }
      end

      def include_modules?
        params[:include_modules] == 'true'
      end

      def lesson_module_response(module_item)
        base_response = {
          id: module_item.id,
          type: module_item.type,
          title: module_item.title,
          description: module_item.description,
          position: module_item.position,
          lesson_id: module_item.lesson_id,
          settings: module_item.settings,
          published: module_item.published?,
          published_at: module_item.published_at,
          created_at: module_item.created_at,
          updated_at: module_item.updated_at
        }

        # Add type-specific data
        case module_item
        when VideoModule
          base_response.merge!({
            cloudflare_stream_id: module_item.cloudflare_stream_id,
            cloudflare_stream_thumbnail: module_item.cloudflare_stream_thumbnail,
            cloudflare_stream_duration: module_item.cloudflare_stream_duration,
            cloudflare_stream_status: module_item.cloudflare_stream_status,
            formatted_duration: module_item.formatted_duration,
            video_ready: module_item.video_ready_for_playback?,
            video_player_data: module_item.video_player_data
          })
        when TextModule
          base_response.merge!({
            content: module_item.content,
            word_count: module_item.word_count,
            reading_time: module_item.reading_time,
            table_of_contents: module_item.table_of_contents,
            excerpt: module_item.excerpt
          })
        when AssessmentModule
          base_response.merge!({
            questions: module_item.questions,
            question_count: module_item.question_count,
            total_points: module_item.total_points,
            passing_score: module_item.passing_score,
            estimated_time: module_item.estimated_time
          })
        when ResourcesModule
          base_response.merge!({
            resources: module_item.resources,
            resource_count: module_item.resource_count,
            file_resources: module_item.file_resources,
            link_resources: module_item.link_resources,
            total_file_size: module_item.total_file_size,
            formatted_total_size: module_item.formatted_total_size
          })
        when ImageModule
          base_response.merge!({
            images: module_item.images,
            image_count: module_item.image_count,
            layout: module_item.layout,
            single_image: module_item.single_image?,
            gallery: module_item.gallery?,
            carousel: module_item.carousel?,
            grid: module_item.grid?
          })
        end

        base_response
      end
    end
  end
end
