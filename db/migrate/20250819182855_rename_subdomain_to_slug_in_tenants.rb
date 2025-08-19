class RenameSubdomainToSlugInTenants < ActiveRecord::Migration[8.0]
  def change
    rename_column :tenants, :subdomain, :slug
    # Remove the add_index line since it already exists
  end
end
