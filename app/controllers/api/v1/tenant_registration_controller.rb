class Api::V1::TenantRegistrationController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  # POST /api/v1/tenant_registration
  def create
    @tenant = Tenant.new(tenant_params)

    # Validate slug availability before saving
    if Tenant.exists?(slug: @tenant.slug)
      render json: { 
        success: false, 
        error: 'Slug is already taken',
        field: 'slug'
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
          slug: @tenant.slug,
          full_domain: @tenant.full_domain,
          dns_record_id: @tenant.dns_record_id
        },
        admin_user: {
          id: admin_user.id,
          email: admin_user.email,
          username: admin_user.username
        },
        message: "Tenant created successfully. Access your tenant at #{@tenant.full_domain}"
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
    params.require(:tenant).permit(:name, :slug, :domain)
  end
end
