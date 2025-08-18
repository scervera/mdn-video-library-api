class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.string :domain
      t.jsonb :branding_settings, default: {}
      t.jsonb :subscription_settings, default: {}
      t.string :stripe_customer_id
      t.string :subscription_status, default: 'active'

      t.timestamps
    end

    add_index :tenants, :subdomain, unique: true
    add_index :tenants, :stripe_customer_id
  end
end
