class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Allow health checks to pass through without tenant validation
    if request.path == '/up'
      return @app.call(env)
    end
    
    tenant_slug = extract_tenant_slug(request)

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
      # No tenant specified - allow the request to proceed
      # (for non-tenant-specific endpoints like health checks)
      @app.call(env)
    end
  ensure
    Current.tenant = nil
  end

  private

  def extract_tenant_slug(request)
    # First try to get tenant from X-Tenant header (for API calls)
    tenant_slug = request.get_header('HTTP_X_TENANT')
    return tenant_slug if tenant_slug.present?

    # Then try to extract from URL path (for frontend routes)
    path = request.path
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
