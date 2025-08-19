class Api::V1::DebugController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def tenant_info
    render json: {
      current_tenant: Current.tenant&.as_json(only: [:id, :name, :slug]),
      tenant_count: Curriculum.count,
      all_curricula: Curriculum.all.map { |c| { id: c.id, title: c.title, tenant_id: c.tenant_id } },
      current_tenant_curricula: Current.tenant ? Curriculum.where(tenant_id: Current.tenant.id).map { |c| { id: c.id, title: c.title, tenant_id: c.tenant_id } } : []
    }
  end
end
