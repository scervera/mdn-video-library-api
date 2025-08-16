module Api
  module V1
    module User
      class NotesController < BaseController
        def index
          notes = current_user.user_notes.includes(:chapter)
          render json: notes.map { |note| note_response(note) }
        end

        def show
          note = current_user.user_notes.find(params[:id])
          render json: note_response(note)
        end

        def create
          note = current_user.user_notes.build(note_params)
          
          if note.save
            render json: note_response(note), status: :created
          else
            render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
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
          params.require(:note).permit(:chapter_id, :content)
        end

        def note_response(note)
          {
            id: note.id,
            chapter_id: note.chapter_id,
            chapter_title: note.chapter.title,
            content: note.content,
            created_at: note.created_at,
            updated_at: note.updated_at
          }
        end
      end
    end
  end
end
