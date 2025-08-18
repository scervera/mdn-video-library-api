class TenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    subdomain = extract_subdomain(request.host)

    if subdomain.present? && subdomain != 'www'
      tenant = Tenant.find_by(subdomain: subdomain)
      if tenant
        Current.tenant = tenant
        @app.call(env)
      else
        # Tenant not found - could redirect to signup or show error
        [404, {'Content-Type' => 'text/html'}, ['Tenant not found']]
      end
    else
      # No subdomain - could be main app or redirect
      @app.call(env)
    end
  ensure
    Current.tenant = nil
  end

  private

  def extract_subdomain(host)
    # Normalize host (strip port if present)
    hostname = host.to_s.split(':').first
    parts = hostname.split('.')

    # Handle acmeX.localhost (two parts) during development
    return parts.first if hostname.end_with?('.localhost') && parts.length == 2

    # Standard multi-level domain e.g. tenant.example.com
    return parts.first if parts.length > 2

    nil
  end
end
