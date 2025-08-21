class FixProfessionalTierPerUserPrice < ActiveRecord::Migration[8.0]
  def change
    # Update all Professional tier billing tiers to have the correct per_user_price
    BillingTier.where(name: 'Professional').update_all(per_user_price: 2.0)
    
    puts "Updated #{BillingTier.where(name: 'Professional').count} Professional tier(s) to have per_user_price: 2.0"
  end
end
