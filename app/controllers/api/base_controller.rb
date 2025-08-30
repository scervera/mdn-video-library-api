class Api::BaseController < ApplicationController
  before_action :set_tenant_context
  before_action :authenticate_user!

  private

  def set_tenant_context
    tenant_slug = request.headers['X-Tenant']
    
    # Skip tenant validation for certain endpoints
    return if skip_tenant_validation?
    
    return render json: { error: 'X-Tenant header required' }, status: :bad_request unless tenant_slug
    
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
      
      # If we have tenant context, scope the user lookup to that tenant
      if Current.tenant
        @current_user = Current.tenant.users.find(decoded['user_id'])
      else
        # Fallback to global user lookup for endpoints that don't require tenant context
        @current_user = User.find(decoded['user_id'])
      end
      
      Current.user = @current_user
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid token' }, status: :unauthorized
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
