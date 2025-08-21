module ApiResponseHelper
  extend ActiveSupport::Concern

  private

  # Standardized success response for list endpoints
  def render_list_response(data, pagination: nil, meta: nil)
    response = { data: data }
    response[:pagination] = pagination if pagination.present?
    response[:meta] = meta if meta.present?
    
    render json: response
  end

  # Standardized success response for single resource endpoints
  def render_single_response(data, meta: nil, status: :ok)
    response = { data: data }
    response[:meta] = meta if meta.present?
    
    render json: response, status: status
  end

  # Standardized success response for action endpoints (create, update, delete)
  def render_action_response(data: nil, message: nil, status: :ok)
    response = {}
    response[:data] = data if data.present?
    response[:meta] = { message: message } if message.present?
    
    render json: response, status: status
  end

  # Standardized error response
  def render_error_response(error_code: nil, message: nil, details: nil, status: :unprocessable_entity)
    error = {}
    error[:code] = error_code if error_code.present?
    error[:message] = message if message.present?
    error[:details] = details if details.present?
    
    render json: { error: error }, status: status
  end

  # Helper for pagination metadata
  def pagination_metadata(collection, page, per_page)
    {
      page: page,
      per_page: per_page,
      total: collection.total_count,
      total_pages: collection.total_pages
    }
  end

  # Helper for validation errors
  def render_validation_errors(record)
    render_error_response(
      error_code: 'validation_error',
      message: 'Validation failed',
      details: record.errors.full_messages,
      status: :unprocessable_entity
    )
  end

  # Helper for not found errors
  def render_not_found_error(resource_name = 'Resource')
    render_error_response(
      error_code: 'not_found',
      message: "#{resource_name} not found",
      status: :not_found
    )
  end

  # Helper for unauthorized errors
  def render_unauthorized_error(message = 'Unauthorized')
    render_error_response(
      error_code: 'unauthorized',
      message: message,
      status: :unauthorized
    )
  end

  # Helper for forbidden errors
  def render_forbidden_error(message = 'Access denied')
    render_error_response(
      error_code: 'forbidden',
      message: message,
      status: :forbidden
    )
  end
end
