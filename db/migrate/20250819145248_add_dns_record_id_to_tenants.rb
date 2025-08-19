class AddDnsRecordIdToTenants < ActiveRecord::Migration[8.0]
  def change
    add_column :tenants, :dns_record_id, :string
  end
end
