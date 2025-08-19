class TenantRegistrationController < ApplicationController

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)

    # Validate subdomain availability before saving
    dns_service = CloudflareDnsService.new
    unless dns_service.subdomain_available?(@tenant.subdomain)
      @tenant.errors.add(:subdomain, "is not available")
      render :new and return
    end

    if @tenant.save
      # Create default admin user
      admin_user = @tenant.users.create!(
        username: params[:admin_username],
        email: params[:admin_email],
        password: params[:admin_password],
        password_confirmation: params[:admin_password],
        first_name: params[:admin_first_name],
        last_name: params[:admin_last_name],
        role: 'admin'
      )

      # Redirect to tenant subdomain
      redirect_to "https://#{@tenant.subdomain}.#{ENV['APP_DOMAIN'] || 'curriculum-library-api.cerveras.com'}/dashboard"
    else
      render :new
    end
  rescue => e
    @tenant.errors.add(:base, "Registration failed: #{e.message}")
    render :new
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name, :subdomain, :domain)
  end
end
