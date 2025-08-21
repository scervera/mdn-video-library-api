class AddStripePriceIdToBillingTiers < ActiveRecord::Migration[8.0]
  def change
    add_column :billing_tiers, :stripe_price_id, :string
    add_index :billing_tiers, :stripe_price_id, unique: true
  end
end
