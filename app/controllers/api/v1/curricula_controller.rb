module Api
  module V1
    class CurriculaController < BaseController
      before_action :set_curriculum, only: [:show, :update, :destroy, :enroll, :enrollment_status]
      before_action :ensure_admin!, except: [:index, :show, :enroll, :enrollment_status]

      def index
    curricula = ::Curriculum.published.ordered
    render json: curricula.map { |curriculum| curriculum_with_progress(curriculum) }
  end

  def show
    render json: curriculum_with_progress(@curriculum)
  end

  def create
    curriculum = Current.tenant.curricula.build(curriculum_params)
    
    if curriculum.save
      render json: curriculum_with_progress(curriculum), status: :created
    else
      render json: { errors: curriculum.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @curriculum.update(curriculum_params)
      render json: curriculum_with_progress(@curriculum)
    else
      render json: { errors: @curriculum.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @curriculum.destroy
      render json: { message: 'Curriculum deleted successfully' }
    else
      render json: { errors: @curriculum.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def enroll
    # Check if user is already enrolled
    if current_user.enrolled_in?(@curriculum)
      render json: { message: 'Already enrolled in this curriculum' }, status: :unprocessable_entity
    else
      # Create initial progress records for all chapters in the curriculum
      @curriculum.chapters.published.ordered.each do |chapter|
        current_user.user_progress.create!(
          chapter: chapter,
          curriculum: @curriculum,
          tenant: Current.tenant,
          completed: false
        )
      end
      
      render json: { 
        message: 'Successfully enrolled in curriculum',
        curriculum_id: @curriculum.id,
        curriculum_title: @curriculum.title
      }
    end
  end

  def enrollment_status
    is_enrolled = current_user.enrolled_in?(@curriculum)
    
    render json: {
      curriculum_id: @curriculum.id,
      curriculum_title: @curriculum.title,
      enrolled: is_enrolled,
      enrollment_date: is_enrolled ? current_user.user_progress.where(curriculum: @curriculum).first.created_at : nil
    }
  end

      private

      def set_curriculum
        @curriculum = Current.tenant.curriculums.find(params[:id])
      end

      def curriculum_params
        params.require(:curriculum).permit(:title, :description, :order_index, :published)
      end

      def curriculum_with_progress(curriculum)
        {
          id: curriculum.id,
          title: curriculum.title,
          description: curriculum.description,
          order_index: curriculum.order_index,
          published: curriculum.published,
          total_chapters: curriculum.total_chapters,
          total_lessons: curriculum.total_lessons,
          completed_chapters: curriculum.completed_chapters_count(current_user),
          completed_lessons: curriculum.completed_lessons_count(current_user),
          enrolled: current_user.enrolled_in?(curriculum),
          chapters: curriculum.chapters.published.ordered.map { |chapter| chapter_with_progress(chapter) }
        }
      end

      def chapter_with_progress(chapter)
        progress = current_user.user_progress.find_by(chapter: chapter, curriculum: chapter.curriculum)
        {
          id: chapter.id,
          title: chapter.title,
          description: chapter.description,
          duration: chapter.duration,
          order_index: chapter.order_index,
          published: chapter.published,
          lessons: chapter.lessons.published.ordered.map { |lesson| lesson_with_progress(lesson) },
          isLocked: chapter.order_index > current_user.completed_chapters_count(chapter.curriculum) + 1,
          completed: progress&.completed || false,
          completed_at: progress&.completed_at,
          total_lessons: chapter.total_lessons,
          completed_lessons: chapter.completed_lessons_count(current_user)
        }
      end

      def lesson_with_progress(lesson)
        progress = current_user.lesson_progress.find_by(lesson: lesson)
        
        lesson_data = {
          id: lesson.id,
          title: lesson.title,
          description: lesson.description,
          content_type: lesson.content_type,
          content: lesson.content,
          media_url: lesson.media_url,
          order_index: lesson.order_index,
          published: lesson.published,
          completed: progress&.completed || false,
          completed_at: progress&.completed_at
        }
        
        # Include lesson modules if requested
        if params[:include_modules] == 'true'
          lesson_data[:lesson_modules] = lesson.lesson_modules.published.ordered.map { |module_obj| module_with_data(module_obj) }
        end
        
        lesson_data
      end
      
      def module_with_data(module_obj)
        base_data = {
          id: module_obj.id,
          type: module_obj.type,
          title: module_obj.title,
          description: module_obj.description,
          position: module_obj.position,
          published: module_obj.published?,
          published_at: module_obj.published_at,
          settings: module_obj.respond_to?(:clean_settings_for_api) ? module_obj.clean_settings_for_api : (module_obj.settings || {})
        }
        
        # Add type-specific data
        case module_obj.type
        when 'ImageModule'
          base_data[:images] = module_obj.attached_images_with_metadata
        when 'TextModule'
          base_data[:content] = module_obj.content
          base_data[:tiptap_content] = module_obj.tiptap_content
          base_data[:word_count] = module_obj.word_count
          base_data[:reading_time] = module_obj.reading_time
          base_data[:table_of_contents] = module_obj.table_of_contents
        when 'VideoModule'
          base_data[:video_url] = module_obj.video_url
          base_data[:video_provider] = module_obj.video_provider
          base_data[:duration] = module_obj.duration
        when 'AssessmentModule'
          base_data[:questions] = module_obj.questions
          base_data[:passing_score] = module_obj.passing_score
        when 'ResourcesModule'
          base_data[:resources] = module_obj.resources
        end
        
        base_data
      end
    end
  end
end
