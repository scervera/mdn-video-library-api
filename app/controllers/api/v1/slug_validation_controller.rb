class Api::V1::SlugValidationController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # GET /api/v1/slug_validation/check
  def check
    slug = params[:slug]&.downcase&.strip
    
    if slug.blank?
      render json: { 
        available: false, 
        error: 'Slug is required' 
      }, status: :bad_request
      return
    end

    # Check if slug is already taken by another tenant
    if Tenant.exists?(slug: slug)
      render json: { 
        available: false, 
        slug: slug,
        error: 'Slug is already taken'
      }
    else
      render json: { 
        available: true, 
        slug: slug,
        full_url: "#{slug}.curriculum.cerveras.com"
      }
    end
  rescue => e
    render json: { 
      available: false, 
      error: "Validation failed: #{e.message}" 
    }, status: :internal_server_error
  end
end
