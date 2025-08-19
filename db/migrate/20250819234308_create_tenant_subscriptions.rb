class CreateTenantSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :tenant_subscriptions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :billing_tier, null: false, foreign_key: true
      t.string :status, null: false, default: 'trial'
      t.datetime :trial_ends_at
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.string :stripe_subscription_id

      t.timestamps
    end

    add_index :tenant_subscriptions, :status
    add_index :tenant_subscriptions, :stripe_subscription_id, unique: true
    add_index :tenant_subscriptions, :trial_ends_at
  end
end
