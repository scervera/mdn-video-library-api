class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    Rails.logger.info "TenantMiddleware: Processing path: #{request.path}"
    
    # Allow health checks to pass through without tenant validation
    if request.path == '/up'
      return @app.call(env)
    end
    
    # Allow configuration endpoint to pass through without tenant validation
    if request.path == '/api/v1/config'
      return @app.call(env)
    end
    
    # Allow webhook endpoints to pass through without tenant validation
    if webhook_endpoint?(request.path)
      return @app.call(env)
    end
    
    # Allow Active Storage endpoints to pass through without tenant validation
    if active_storage_endpoint?(request.path)
      Rails.logger.info "Active Storage endpoint detected: #{request.path}"
      return @app.call(env)
    end
    
    # For API endpoints, require X-Tenant header
    if api_endpoint?(request.path)
      tenant_slug = request.get_header('HTTP_X_TENANT')
      
      if tenant_slug.blank?
        return [400, {'Content-Type' => 'application/json'}, ['{"error": "X-Tenant header is required for API endpoints"}']]
      end
      
      tenant = Tenant.find_by(slug: tenant_slug)
      if tenant
        Current.tenant = tenant
        result = @app.call(env)
        Current.tenant = nil
        result
      else
        # Tenant not found
        [404, {'Content-Type' => 'application/json'}, ['{"error": "Tenant not found"}']]
      end
    else
      # For non-API endpoints, try to extract tenant from URL path
      tenant_slug = extract_tenant_from_path(request.path)
      
      if tenant_slug.present?
        tenant = Tenant.find_by(slug: tenant_slug)
        if tenant
          Current.tenant = tenant
          result = @app.call(env)
          Current.tenant = nil
          result
        else
          # Tenant not found
          [404, {'Content-Type' => 'application/json'}, ['{"error": "Tenant not found"}']]
        end
      else
        # No tenant specified for non-API endpoints - allow to proceed
        @app.call(env)
      end
    end
  end

  private

  def api_endpoint?(path)
    # Check if the path starts with /api
    path.start_with?('/api')
  end

  def webhook_endpoint?(path)
    # Check if the path is a webhook endpoint
    path.include?('/webhooks/')
  end

  def active_storage_endpoint?(path)
    # Check if the path is an Active Storage endpoint
    path.start_with?('/rails/active_storage/')
  end

  def extract_tenant_from_path(path)
    path_parts = path.split('/').reject(&:blank?)
    
    # Look for tenant slug in the first part of the path
    # e.g., /acme1/api/v1/curricula -> acme1
    # e.g., /acme1/dashboard -> acme1
    return path_parts.first if path_parts.any? && valid_tenant_slug?(path_parts.first)
    
    nil
  end

  def valid_tenant_slug?(slug)
    # Check if it matches the tenant slug format
    slug.match?(/\A[a-z0-9-]+\z/)
  end
end
