class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Debug logging
    Rails.logger.debug "TenantMiddleware: Path = #{request.path}"
    Rails.logger.debug "TenantMiddleware: X-Tenant header = #{request.get_header('HTTP_X_TENANT')}"
    Rails.logger.debug "TenantMiddleware: All headers = #{env.select { |k, v| k.start_with?('HTTP_') }}"
    
    # Allow health checks to pass through without tenant validation
    if request.path == '/up'
      return @app.call(env)
    end
    
    # For API endpoints, require X-Tenant header
    if api_endpoint?(request.path)
      tenant_slug = request.get_header('HTTP_X_TENANT')
      
      Rails.logger.debug "TenantMiddleware: API endpoint detected, tenant_slug = #{tenant_slug}"
      
      if tenant_slug.blank?
        Rails.logger.debug "TenantMiddleware: X-Tenant header missing, returning 400"
        return [400, {'Content-Type' => 'application/json'}, ['{"error": "X-Tenant header is required for API endpoints"}']]
      end
      
      tenant = Tenant.find_by(slug: tenant_slug)
      if tenant
        Rails.logger.debug "TenantMiddleware: Setting Current.tenant = #{tenant.name}"
        Current.tenant = tenant
        @app.call(env)
      else
        Rails.logger.debug "TenantMiddleware: Tenant not found for slug = #{tenant_slug}"
        # Tenant not found
        [404, {'Content-Type' => 'application/json'}, ['{"error": "Tenant not found"}']]
      end
    else
      # For non-API endpoints, try to extract tenant from URL path
      tenant_slug = extract_tenant_from_path(request.path)
      
      Rails.logger.debug "TenantMiddleware: Non-API endpoint, extracted tenant_slug = #{tenant_slug}"
      
      if tenant_slug.present?
        tenant = Tenant.find_by(slug: tenant_slug)
        if tenant
          Current.tenant = tenant
          @app.call(env)
        else
          # Tenant not found
          [404, {'Content-Type' => 'application/json'}, ['{"error": "Tenant not found"}']]
        end
      else
        # No tenant specified for non-API endpoints - allow to proceed
        @app.call(env)
      end
    end
  ensure
    Current.tenant = nil
  end

  private

  def api_endpoint?(path)
    # Check if the path starts with /api
    path.start_with?('/api')
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
