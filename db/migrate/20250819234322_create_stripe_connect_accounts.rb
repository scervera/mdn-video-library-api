class CreateStripeConnectAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_connect_accounts do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :account_id, null: false
      t.string :status, null: false, default: 'pending'
      t.boolean :charges_enabled, default: false, null: false
      t.boolean :payouts_enabled, default: false, null: false

      t.timestamps
    end

    add_index :stripe_connect_accounts, :account_id, unique: true
    add_index :stripe_connect_accounts, :status
  end
end
