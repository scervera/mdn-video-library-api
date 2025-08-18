class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Scope all queries to current tenant (only for models that have tenant_id column)
  default_scope { where(tenant_id: Current.tenant.id) if Current.tenant && column_names.include?('tenant_id') }

  # Ensure tenant is set on creation
  before_create :set_tenant

  private

  def set_tenant
    self.tenant_id = Current.tenant.id if respond_to?(:tenant_id=) && tenant_id.nil? && Current.tenant
  end
end
