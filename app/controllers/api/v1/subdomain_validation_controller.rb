class Api::V1::SubdomainValidationController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # GET /api/v1/subdomain_validation/check
  def check
    subdomain = params[:subdomain]&.downcase&.strip
    
    if subdomain.blank?
      render json: { 
        available: false, 
        error: 'Subdomain is required' 
      }, status: :bad_request
      return
    end

    dns_service = CloudflareDnsService.new
    
    if dns_service.subdomain_available?(subdomain)
      render json: { 
        available: true, 
        subdomain: subdomain,
        full_domain: "#{subdomain}.cerveras.com"
      }
    else
      render json: { 
        available: false, 
        subdomain: subdomain,
        error: 'Subdomain is not available'
      }
    end
  rescue => e
    render json: { 
      available: false, 
      error: "Validation failed: #{e.message}" 
    }, status: :internal_server_error
  end
end
