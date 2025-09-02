class Api::BaseController < ApplicationController
  before_action :set_tenant_context
  before_action :authenticate_user!

  private

  def set_tenant_context
    # Extract tenant slug from URL path (e.g., /acme1/api/v1/lessons/1)
    tenant_slug = request.path.split('/')[1]
    
    # Skip tenant validation for certain endpoints
    return if skip_tenant_validation?
    
    return render json: { error: 'Tenant slug required in URL path' }, status: :bad_request unless tenant_slug
    
    tenant = Tenant.find_by(slug: tenant_slug)
    return render json: { error: 'Invalid tenant' }, status: :unauthorized unless tenant
    
    Current.tenant = tenant
  end

  def skip_tenant_validation?
    # Skip tenant validation for health checks and certain public endpoints
    controller_name == 'config' || 
    action_name == 'health' ||
    request.path == '/up'
  end

  def authenticate_user!
    # Skip authentication for certain endpoints
    return if skip_authentication?
    
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'No token provided' }, status: :unauthorized unless token

    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      
      # Find user by ID
      user = User.find(decoded['user_id'])
      
      # Verify user belongs to the tenant from the URL path
      unless user.tenant_id == Current.tenant.id
        render json: { error: 'Access denied to this tenant' }, status: :forbidden
        return
      end
      
      @current_user = user
      Current.user = @current_user
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def skip_authentication?
    # Skip authentication for public endpoints
    controller_name == 'config' || 
    action_name == 'health' ||
    request.path == '/up'
  end

  def current_user
    @current_user
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end
