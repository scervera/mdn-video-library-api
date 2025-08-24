module Api
  module V1
    class BookmarksController < BaseController
      before_action :set_lesson
      before_action :set_bookmark, only: [:show, :update, :destroy, :share]

      # GET /api/v1/lessons/:lesson_id/bookmarks
      def index
        bookmarks = current_user.bookmarks.for_lesson(@lesson.id).ordered_by_timestamp
        render json: bookmarks.map { |bookmark| bookmark_response(bookmark) }
      end

      # GET /api/v1/lessons/:lesson_id/bookmarks/:id
      def show
        unless @bookmark.can_be_accessed_by?(current_user)
          render json: { error: 'Access denied' }, status: :forbidden
          return
        end
        
        render json: bookmark_response(@bookmark)
      end

      # POST /api/v1/lessons/:lesson_id/bookmarks
      def create
        bookmark = current_user.bookmarks.build(bookmark_params)
        bookmark.lesson = @lesson
        bookmark.tenant = Current.tenant

        if bookmark.save
          render json: bookmark_response(bookmark), status: :created
        else
          render json: { 
            success: false, 
            errors: bookmark.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/lessons/:lesson_id/bookmarks/:id
      def update
        unless @bookmark.user_id == current_user.id
          render json: { error: 'Access denied' }, status: :forbidden
          return
        end
        
        if @bookmark.update(bookmark_params)
          render json: bookmark_response(@bookmark)
        else
          render json: { 
            success: false, 
            errors: @bookmark.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/lessons/:lesson_id/bookmarks/:id
      def destroy
        unless @bookmark.user_id == current_user.id
          render json: { error: 'Access denied' }, status: :forbidden
          return
        end
        
        @bookmark.destroy
        render json: { success: true, message: 'Bookmark deleted successfully' }
      end

      # PUT /api/v1/lessons/:lesson_id/bookmarks/:id/share
      def share
        unless @bookmark.user_id == current_user.id
          render json: { error: 'Access denied' }, status: :forbidden
          return
        end
        
        if @bookmark.update(share_params)
          render json: bookmark_response(@bookmark)
        else
          render json: { 
            success: false, 
            errors: @bookmark.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      private

      def set_lesson
        @lesson = Current.tenant.lessons.find(params[:lesson_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Lesson not found' }, status: :not_found
      end

      def set_bookmark
        @bookmark = Bookmark.joins(:lesson => { :curriculum => :tenant })
          .where(curricula: { tenant: Current.tenant })
          .find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Bookmark not found' }, status: :not_found
      end

      def bookmark_params
        params.require(:bookmark).permit(
          :title, :notes, :content_type, :privacy_level,
          :timestamp, :in_sec, :out_sec, shared_with: []
        )
      end

      def share_params
        params.require(:share).permit(:privacy_level, shared_with: [])
      end

      def bookmark_response(bookmark)
        {
          id: bookmark.id,
          title: bookmark.title,
          notes: bookmark.notes,
          content_type: bookmark.content_type,
          privacy_level: bookmark.privacy_level,
          timestamp: bookmark.timestamp,
          in_sec: bookmark.in_sec,
          out_sec: bookmark.out_sec,
          duration: bookmark.duration,
          lesson_id: bookmark.lesson_id,
          user_id: bookmark.user_id,
          shared_with: bookmark.shared_with || [],
          created_at: bookmark.created_at,
          updated_at: bookmark.updated_at,
          formatted_timestamp: bookmark.formatted_timestamp,
          formatted_timestamp_with_hours: bookmark.formatted_timestamp_with_hours,
          user: {
            id: bookmark.user.id,
            username: bookmark.user.username,
            name: bookmark.user.full_name,
            email: bookmark.user.email
          },
          lesson: {
            id: bookmark.lesson.id,
            title: bookmark.lesson.title
          }
        }
      end
    end
  end
end
