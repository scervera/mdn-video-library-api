module Api
  module V1
    class LessonModulesController < BaseController
      before_action :set_lesson, only: [:index, :create, :reorder]
      before_action :set_lesson_module, only: [:show, :update, :destroy, :upload_file, :remove_file]
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
        # Handle image data if present
        if params[:lesson_module][:images].present?
          process_image_data(params[:lesson_module][:images])
        end
        
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
        modules_data = params[:modules] || params[:module_ids]
        
        unless modules_data.is_a?(Array) && modules_data.length == @lesson.lesson_modules.count
          return render json: { 
            error: 'Invalid modules data', 
            expected_count: @lesson.lesson_modules.count,
            received_count: modules_data&.length || 0
          }, status: :unprocessable_entity
        end

        begin
          # Handle both formats:
          # 1. Simple array of IDs: [1, 2, 3]
          # 2. Array of objects with positions: [{id: 1, position: 1}, {id: 2, position: 2}]
          
          if modules_data.first.is_a?(Hash) || modules_data.first.is_a?(ActionController::Parameters)
            # Format 2: Array of objects with explicit positions
            ActiveRecord::Base.transaction do
              # First, temporarily set all positions to high values to avoid conflicts
              temp_positions = {}
              modules_data.each_with_index do |module_data, index|
                # Convert ActionController::Parameters to hash if needed
                module_data = module_data.to_unsafe_h if module_data.is_a?(ActionController::Parameters)
                
                # Handle both string and symbol keys
                module_id = module_data['id'] || module_data[:id]
                position = module_data['position'] || module_data[:position]
                
                if module_id && position
                  temp_positions[module_id.to_i] = position.to_i
                  # Set temporary position to avoid conflicts
                  @lesson.lesson_modules.find(module_id.to_i).update!(position: 10000 + index)
                else
                  raise ArgumentError, "Missing id or position in module data: #{module_data}"
                end
              end
              
              # Now set the final positions
              temp_positions.each do |module_id, final_position|
                @lesson.lesson_modules.find(module_id).update!(position: final_position)
              end
            end
          else
            # Format 1: Simple array of IDs - use existing method
            @lesson.reorder_modules(modules_data)
          end
          
          render json: { 
            message: 'Modules reordered successfully',
            modules_count: @lesson.lesson_modules.count
          }
        rescue ActiveRecord::RecordNotFound => e
          render json: { error: "Module not found: #{e.message}" }, status: :not_found
        rescue ArgumentError => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue => e
          render json: { error: "Reordering failed: #{e.message}" }, status: :unprocessable_entity
        end
      end

      # File upload endpoints
      def upload_file
        unless file_upload_allowed?
          render json: { error: 'File upload not allowed for this module type' }, status: :unprocessable_entity
          return
        end

        file = params[:file]
        metadata = params[:metadata] || {}

        # Handle metadata if it comes as a JSON string
        if metadata.is_a?(String)
          begin
            metadata = JSON.parse(metadata)
          rescue JSON::ParserError
            metadata = {}
          end
        end

        # Validate file
        validation_result = validate_file(file)
        unless validation_result[:valid]
          render json: { error: validation_result[:error] }, status: :unprocessable_entity
          return
        end

        begin
          case @lesson_module.type
          when 'ResourcesModule'
            upload_to_resources_module(file, metadata)
          when 'ImageModule'
            upload_to_image_module(file, metadata)
          when 'TextModule'
            upload_to_text_module(file, metadata)
          else
            render json: { error: 'Unsupported module type for file upload' }, status: :unprocessable_entity
            return
          end

          render json: lesson_module_response(@lesson_module)
        rescue => e
          render json: { error: "File upload failed: #{e.message}" }, status: :unprocessable_entity
        end
      end

      def remove_file
        file_index = params[:file_index]&.to_i

        if file_index.nil?
          render json: { error: 'File index is required' }, status: :unprocessable_entity
          return
        end

        begin
          case @lesson_module.type
          when 'ResourcesModule'
            @lesson_module.remove_file_with_metadata(file_index)
          when 'ImageModule'
            @lesson_module.remove_image_with_metadata(file_index)
          when 'TextModule'
            @lesson_module.remove_image_with_metadata(file_index)
          else
            render json: { error: 'Unsupported module type for file removal' }, status: :unprocessable_entity
            return
          end

          render json: lesson_module_response(@lesson_module)
        rescue => e
          render json: { error: "File removal failed: #{e.message}" }, status: :unprocessable_entity
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
          :layout, settings: {}
        )
        
        # Handle settings as JSON if it comes as a string
        if permitted_params[:settings].is_a?(String)
          permitted_params[:settings] = JSON.parse(permitted_params[:settings])
        end
        
        permitted_params
      end

      def process_image_data(images_data)
        return unless images_data.is_a?(Array)
        
        images_data.each do |image_data|
          # Skip if this is already an attached image (has attachment ID)
          next if image_data['attachment']&.dig('id').present?
          
          # This is a new image that needs to be processed
          # For now, we'll just log it since the frontend should use the upload endpoint
          Rails.logger.info "Received image data in update: #{image_data['filename']}"
        end
      end

      def ensure_admin!
        unless current_user.role == 'admin'
          render_forbidden_error('Admin access required')
        end
      end

      # File upload validation and handling
      def file_upload_allowed?
        %w[ResourcesModule ImageModule TextModule].include?(@lesson_module.type)
      end

      def validate_file(file)
        return { valid: false, error: 'No file provided' } if file.blank?

        # Check file size
        max_size = get_max_file_size
        if file.size > max_size
          return { valid: false, error: "File size exceeds maximum allowed size of #{format_file_size(max_size)}" }
        end

        # Check file type
        allowed_types = get_allowed_file_types
        unless allowed_types.include?(file.content_type)
          return { valid: false, error: "File type not allowed. Allowed types: #{allowed_types.join(', ')}" }
        end

        { valid: true }
      end

      def get_max_file_size
        case @lesson_module.type
        when 'ResourcesModule'
          50.megabytes
        when 'ImageModule'
          10.megabytes
        when 'TextModule'
          10.megabytes
        else
          1.megabyte
        end
      end

      def get_allowed_file_types
        case @lesson_module.type
        when 'ResourcesModule'
          [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'application/vnd.ms-powerpoint',
            'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'text/plain',
            'text/csv',
            'application/zip',
            'application/x-zip-compressed'
          ]
        when 'ImageModule', 'TextModule'
          [
            'image/jpeg',
            'image/jpg',
            'image/png',
            'image/gif',
            'image/webp',
            'image/svg+xml'
          ]
        else
          []
        end
      end

      def format_file_size(bytes)
        units = %w[B KB MB GB]
        size = bytes.to_f
        unit_index = 0
        
        while size >= 1024 && unit_index < units.length - 1
          size /= 1024
          unit_index += 1
        end
        
        "#{size.round(1)} #{units[unit_index]}"
      end

      def upload_to_resources_module(file, metadata)
        @lesson_module.add_file_with_metadata(
          file,
          title: metadata[:title],
          description: metadata[:description],
          alt_text: metadata[:alt_text]
        )
      end

      def upload_to_image_module(file, metadata)
        @lesson_module.add_image_with_metadata(
          file,
          title: metadata[:title],
          alt_text: metadata[:alt_text],
          description: metadata[:description]
        )
      end

      def upload_to_text_module(file, metadata)
        @lesson_module.add_image_with_metadata(
          file,
          title: metadata[:title],
          alt_text: metadata[:alt_text],
          description: metadata[:description]
        )
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
            excerpt: module_item.excerpt,
            images: module_item.attached_images_with_metadata
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
            resources: module_item.attached_files_with_metadata,
            resource_count: module_item.resource_count,
            file_resources: module_item.file_resources,
            link_resources: module_item.link_resources,
            total_file_size: module_item.total_file_size,
            formatted_total_size: module_item.formatted_total_size
          })
        when ImageModule
          base_response.merge!({
            images: module_item.attached_images_with_metadata,
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
