module Api
  module V1
    class ChaptersController < BaseController
      before_action :set_chapter, only: [:show, :update, :destroy, :complete]
      before_action :ensure_admin!, except: [:index, :show, :complete]

      def index
    if params[:curriculum_id]
      curriculum = ::Curriculum.find(params[:curriculum_id])
      chapters = curriculum.chapters.published.ordered
    else
      chapters = ::Chapter.published.ordered
    end
    render json: chapters.map { |chapter| chapter_with_progress(chapter) }
  end

  def show
    render json: chapter_with_progress(@chapter)
  end

  def create
    curriculum = Current.tenant.curricula.find(params[:curriculum_id])
    chapter = curriculum.chapters.build(chapter_params)
    
    if chapter.save
      render json: chapter_with_progress(chapter), status: :created
    else
      render json: { errors: chapter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @chapter.update(chapter_params)
      render json: chapter_with_progress(@chapter)
    else
      render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @chapter.destroy
      render json: { message: 'Chapter deleted successfully' }
    else
      render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def complete
    curriculum = @chapter.curriculum
    progress = current_user.user_progress.find_or_create_by(chapter: @chapter, curriculum: curriculum)
    progress.update(completed: true, completed_at: Time.current)
    render json: { message: 'Chapter completed' }
  end

      private

      def set_chapter
        @chapter = Current.tenant.chapters.find(params[:id])
      end

      def chapter_params
        params.require(:chapter).permit(:title, :description, :duration, :order_index, :published)
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
        {
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
      end
    end
  end
end
