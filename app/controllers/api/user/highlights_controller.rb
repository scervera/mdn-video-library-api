class Api::User::HighlightsController < Api::BaseController
  def index
    highlights = current_user.user_highlights.includes(:chapter)
    render json: highlights.map { |highlight| highlight_response(highlight) }
  end

  def show
    highlight = current_user.user_highlights.find(params[:id])
    render json: highlight_response(highlight)
  end

  def create
    highlight = current_user.user_highlights.build(highlight_params)
    
    if highlight.save
      render json: highlight_response(highlight), status: :created
    else
      render json: { errors: highlight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    highlight = current_user.user_highlights.find(params[:id])
    
    if highlight.update(highlight_params)
      render json: highlight_response(highlight)
    else
      render json: { errors: highlight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    highlight = current_user.user_highlights.find(params[:id])
    highlight.destroy
    render json: { message: 'Highlight deleted successfully' }
  end

  private

  def highlight_params
    params.require(:highlight).permit(:chapter_id, :highlighted_text)
  end

  def highlight_response(highlight)
    {
      id: highlight.id,
      chapter_id: highlight.chapter_id,
      chapter_title: highlight.chapter.title,
      highlighted_text: highlight.highlighted_text,
      created_at: highlight.created_at,
      updated_at: highlight.updated_at
    }
  end
end
