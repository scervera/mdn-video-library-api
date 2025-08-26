module Api
  module V1
    class LessonModulesController < BaseController
      before_action :set_lesson, only: [:index, :create, :reorder]
      before_action :set_lesson_module, only: [:show, :update, :destroy]
      before_action :ensure_admin!, except: [:index, :show]

      def index
        lesson_modules = @lesson.lesson_modules.ordered
        render json: lesson_modules.map { |module_item| lesson_module_response(module_item) }
      end

      def show
        render json: lesson_module_response(@lesson_module)
      end

      def create
        lesson_module = @lesson.lesson_modules.build(lesson_module_params)
        
        if lesson_module.save
          render json: lesson_module_response(lesson_module), status: :created
        else
          render json: { errors: lesson_module.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @lesson_module.update(lesson_module_params)
          render json: lesson_module_response(@lesson_module)
        else
          render json: { errors: @lesson_module.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @lesson_module.destroy
          render json: { message: 'Module deleted successfully' }
        else
          render json: { errors: @lesson_module.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def reorder
        module_ids = params[:module_ids]
        
        unless module_ids.is_a?(Array) && module_ids.length == @lesson.lesson_modules.count
          return render json: { error: 'Invalid module_ids array' }, status: :unprocessable_entity
        end

        begin
          @lesson.reorder_modules(module_ids)
          render json: { message: 'Modules reordered successfully' }
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_lesson
        @lesson = Current.tenant.lessons.find(params[:lesson_id])
      end

      def set_lesson_module
        @lesson_module = Current.tenant.lessons.find(params[:lesson_id]).lesson_modules.find(params[:id])
      end

      def lesson_module_params
        permitted_params = params.require(:lesson_module).permit(
          :type, :title, :description, :position, :published_at,
          :cloudflare_stream_id, :cloudflare_stream_thumbnail, 
          :cloudflare_stream_duration, :cloudflare_stream_status, :content,
          settings: {}
        )
        
        # Handle settings as JSON if it comes as a string
        if permitted_params[:settings].is_a?(String)
          permitted_params[:settings] = JSON.parse(permitted_params[:settings])
        end
        
        permitted_params
      end

      def ensure_admin!
        unless current_user.role == 'admin'
          render_forbidden_error('Admin access required')
        end
      end

      def lesson_module_response(module_item)
        base_response = {
          id: module_item.id,
          type: module_item.type,
          title: module_item.title,
          description: module_item.description,
          position: module_item.position,
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
