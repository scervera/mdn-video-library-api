class CreateUserSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_subscriptions do |t|
      t.references :tenant_subscription, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.string :status, null: false, default: 'active'
      t.string :stripe_subscription_id
      t.decimal :monthly_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :user_subscriptions, :status
    add_index :user_subscriptions, :stripe_subscription_id, unique: true
    add_index :user_subscriptions, [:tenant_subscription_id, :user_id], unique: true
  end
end
