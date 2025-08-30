class Api::V1::ConfigController < Api::BaseController
  # No authentication required for configuration endpoint
  skip_before_action :authenticate_user!

  def index
    render json: {
      cloudflare_subdomain: Rails.application.config_for(:cloudflare)[:subdomain],
      root_domain: ENV['ROOT_DOMAIN'] || 'cerveras.com'
    }
  end
end

