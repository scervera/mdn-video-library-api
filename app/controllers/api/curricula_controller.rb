class Api::CurriculaController < Api::BaseController
  def index
    curricula = Curriculum.published.ordered
    render json: curricula.map { |curriculum| curriculum_with_progress(curriculum) }
  end

  def show
    curriculum = Curriculum.find(params[:id])
    render json: curriculum_with_progress(curriculum)
  end

  def enroll
    curriculum = Curriculum.find(params[:id])
    
    # Check if user is already enrolled
    if current_user.enrolled_in?(curriculum)
      render json: { message: 'Already enrolled in this curriculum' }, status: :unprocessable_entity
    else
      # Create initial progress records for all chapters in the curriculum
      curriculum.chapters.published.ordered.each do |chapter|
        current_user.user_progress.create!(
          chapter: chapter,
          curriculum: curriculum,
          completed: false
        )
      end
      
      render json: { 
        message: 'Successfully enrolled in curriculum',
        curriculum_id: curriculum.id,
        curriculum_title: curriculum.title
      }
    end
  end

  def enrollment_status
    curriculum = Curriculum.find(params[:id])
    is_enrolled = current_user.enrolled_in?(curriculum)
    
    render json: {
      curriculum_id: curriculum.id,
      curriculum_title: curriculum.title,
      enrolled: is_enrolled,
      enrollment_date: is_enrolled ? current_user.user_progress.where(curriculum: curriculum).first.created_at : nil
    }
  end

  private

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
