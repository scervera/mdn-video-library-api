#!/usr/bin/env ruby

# Debug script to test subscription creation
require_relative 'config/environment'

puts "🔍 Debugging Subscription Creation"
puts "=================================="

# Test billing configuration
config = BillingConfiguration.current
puts "📋 Available tiers: #{config.tier_names.join(', ')}"

# Test tier lookup
tier_id = 'starter'
tier_data = config.get_tier(tier_id)
puts "🔍 Looking up tier '#{tier_id}':"
if tier_data
  puts "   ✅ Found: #{tier_data['name']} - $#{tier_data['monthly_price']}/month"
else
  puts "   ❌ Not found"
end

# Test with different parameter names
puts "\n🔍 Testing parameter variations:"
['tier_id', 'billing_tier_id', 'tierId'].each do |param_name|
  puts "   Testing '#{param_name}': #{config.get_tier(param_name) ? '✅ Found' : '❌ Not found'}"
end

# Test subscription params
puts "\n🔍 Testing subscription params:"
test_params = {
  'tier_id' => 'starter',
  'billing_tier_id' => 'starter', 
  'tierId' => 'starter'
}

test_params.each do |param_name, value|
  tier_data = config.get_tier(value)
  puts "   #{param_name} = '#{value}': #{tier_data ? '✅ Valid' : '❌ Invalid'}"
end

puts "\n✅ Debug complete!"
