namespace :stripe do
  desc "Set up Stripe prices for existing billing tiers"
  task setup_prices: :environment do
    puts "Setting up Stripe prices for billing tiers..."
    
    stripe_service = StripeService.new
    
    BillingTier.find_each do |billing_tier|
      if billing_tier.stripe_price_id.blank?
        puts "Creating Stripe price for #{billing_tier.name} tier..."
        begin
          price_id = stripe_service.ensure_billing_tier_price(billing_tier)
          puts "  ✅ Created price: #{price_id}"
        rescue => e
          puts "  ❌ Failed to create price for #{billing_tier.name}: #{e.message}"
        end
      else
        puts "  ⏭️  #{billing_tier.name} already has price: #{billing_tier.stripe_price_id}"
      end
    end
    
    puts "Stripe price setup complete!"
  end

  desc "Set up Stripe customers for existing tenants"
  task setup_customers: :environment do
    puts "Setting up Stripe customers for tenants..."
    
    stripe_service = StripeService.new
    
    Tenant.find_each do |tenant|
      if tenant.stripe_customer_id.blank?
        puts "Creating Stripe customer for #{tenant.name}..."
        begin
          customer_id = stripe_service.ensure_tenant_customer(tenant)
          puts "  ✅ Created customer: #{customer_id}"
        rescue => e
          puts "  ❌ Failed to create customer for #{tenant.name}: #{e.message}"
        end
      else
        puts "  ⏭️  #{tenant.name} already has customer: #{tenant.stripe_customer_id}"
      end
    end
    
    puts "Stripe customer setup complete!"
  end

  desc "Set up complete Stripe integration"
  task setup: :environment do
    puts "Setting up complete Stripe integration..."
    
    Rake::Task['stripe:setup_customers'].invoke
    Rake::Task['stripe:setup_prices'].invoke
    
    puts "Stripe integration setup complete!"
  end
end
