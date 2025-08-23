class Api::User::NotesController < Api::BaseController
  def index
    notes = current_user.user_notes.includes(:chapter, :lesson)
    render json: notes.map { |note| note_response(note) }
  end

  def show
    note = current_user.user_notes.find(params[:id])
    render json: note_response(note)
  end

  def create
    # Handle both old format (chapter_id) and new format (lessonId)
    if params[:lessonId].present?
      # New format: lesson-level notes
      lesson_id = params[:lessonId]
      notes_content = params[:notes]
      
      # Find or create note for this lesson
      note = current_user.user_notes.find_or_initialize_by(lesson_id: lesson_id)
      note.content = notes_content
      note.curriculum_id = Lesson.find(lesson_id).chapter.curriculum_id
      note.tenant = Current.tenant
      
      if note.save
        render json: { success: true, note: note_response(note) }, status: :ok
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    else
      # Old format: chapter-level notes
      note = current_user.user_notes.build(note_params)
      
      if note.save
        render json: note_response(note), status: :created
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    note = current_user.user_notes.find(params[:id])
    
    if note.update(note_params)
      render json: note_response(note)
    else
      render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    note = current_user.user_notes.find(params[:id])
    note.destroy
    render json: { message: 'Note deleted successfully' }
  end

  private

  def note_params
    params.require(:note).permit(:chapter_id, :lesson_id, :content)
  end

  def note_response(note)
    response = {
      id: note.id,
      content: note.content,
      created_at: note.created_at,
      updated_at: note.updated_at
    }
    
    if note.chapter_id.present?
      response.merge!({
        chapter_id: note.chapter_id,
        chapter_title: note.chapter&.title
      })
    end
    
    if note.lesson_id.present?
      response.merge!({
        lesson_id: note.lesson_id,
        lesson_title: note.lesson&.title
      })
    end
    
    response
  end
end
