module Api
  module V1
    class ChaptersController < BaseController
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
    chapter = ::Chapter.find(params[:id])
    render json: chapter_with_progress(chapter)
  end

  def complete
    chapter = ::Chapter.find(params[:id])
        curriculum = chapter.curriculum
        progress = current_user.user_progress.find_or_create_by(chapter: chapter, curriculum: curriculum)
        progress.update(completed: true, completed_at: Time.current)
        render json: { message: 'Chapter completed' }
      end

      private

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
