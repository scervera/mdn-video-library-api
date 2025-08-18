class TenantSettingsController < ApplicationController
  before_action :ensure_admin

  def edit
    @tenant = Current.tenant
  end

  def update
    @tenant = Current.tenant

    if @tenant.update(tenant_params)
      redirect_to tenant_settings_path, notice: 'Settings updated successfully'
    else
      render :edit
    end
  end

  private

  def tenant_params
    params.require(:tenant).permit(
      branding_settings: [:primary_color, :secondary_color, :accent_color, :company_name, :logo_url]
    )
  end

  def ensure_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied'
    end
  end
end
