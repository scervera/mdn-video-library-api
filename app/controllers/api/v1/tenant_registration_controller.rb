class Api::V1::TenantRegistrationController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # POST /api/v1/tenant_registration
  def create
    @tenant = Tenant.new(tenant_params)

    # Validate subdomain availability before saving
    dns_service = CloudflareDnsService.new
    unless dns_service.subdomain_available?(@tenant.subdomain)
      render json: { 
        success: false, 
        error: 'Subdomain is not available',
        field: 'subdomain'
      }, status: :unprocessable_entity
      return
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

      render json: {
        success: true,
        tenant: {
          id: @tenant.id,
          name: @tenant.name,
          subdomain: @tenant.subdomain,
          full_domain: @tenant.full_domain,
          dns_record_id: @tenant.dns_record_id
        },
        admin_user: {
          id: admin_user.id,
          email: admin_user.email,
          username: admin_user.username
        },
        message: "Tenant created successfully. DNS record created for #{@tenant.full_domain}"
      }, status: :created
    else
      render json: { 
        success: false, 
        errors: @tenant.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue => e
    render json: { 
      success: false, 
      error: "Registration failed: #{e.message}" 
    }, status: :internal_server_error
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name, :subdomain, :domain)
  end
end
