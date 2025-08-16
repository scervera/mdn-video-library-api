class Api::BookmarksController < Api::BaseController
  before_action :set_lesson
  before_action :set_bookmark, only: [:show, :update, :destroy]

  # GET /api/lessons/:lesson_id/bookmarks
  def index
    bookmarks = current_user.bookmarks.for_lesson(@lesson.id).ordered_by_timestamp
    render json: bookmarks.map { |bookmark| bookmark_response(bookmark) }
  end

  # GET /api/lessons/:lesson_id/bookmarks/:id
  def show
    render json: bookmark_response(@bookmark)
  end

  # POST /api/lessons/:lesson_id/bookmarks
  def create
    bookmark = current_user.bookmarks.build(bookmark_params)
    bookmark.lesson = @lesson

    if bookmark.save
      render json: bookmark_response(bookmark), status: :created
    else
      render json: { errors: bookmark.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/lessons/:lesson_id/bookmarks/:id
  def update
    if @bookmark.update(bookmark_params)
      render json: bookmark_response(@bookmark)
    else
      render json: { errors: @bookmark.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/lessons/:lesson_id/bookmarks/:id
  def destroy
    @bookmark.destroy
    render json: { message: 'Bookmark deleted successfully' }
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:lesson_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Lesson not found' }, status: :not_found
  end

  def set_bookmark
    @bookmark = current_user.bookmarks.for_lesson(@lesson.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Bookmark not found' }, status: :not_found
  end

  def bookmark_params
    params.require(:bookmark).permit(:title, :notes, :timestamp)
  end

  def bookmark_response(bookmark)
    {
      id: bookmark.id,
      title: bookmark.title,
      notes: bookmark.notes,
      timestamp: bookmark.timestamp,
      formatted_timestamp: bookmark.formatted_timestamp,
      formatted_timestamp_with_hours: bookmark.formatted_timestamp_with_hours,
      lesson_id: bookmark.lesson_id,
      user_id: bookmark.user_id,
      created_at: bookmark.created_at,
      updated_at: bookmark.updated_at
    }
  end
end
