#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Testing Cloudflare DNS Service ==="

# Initialize the service
dns_service = CloudflareDnsService.new

puts "\n1. Testing subdomain validation:"
test_subdomains = ['test123', 'invalid-subdomain--', 'www', 'api', 'admin', 'a', 'very-long-subdomain-name-that-exceeds-the-maximum-length-allowed']

test_subdomains.each do |subdomain|
  available = dns_service.subdomain_available?(subdomain)
  puts "  #{subdomain}: #{available ? '✅ Available' : '❌ Not available'}"
end

puts "\n2. Testing DNS record operations:"
test_subdomain = "test-#{Time.current.to_i}"

puts "  Creating subdomain: #{test_subdomain}"
result = dns_service.create_subdomain(test_subdomain)

if result[:success]
  puts "  ✅ DNS record created successfully"
  puts "  Record ID: #{result[:record_id]}"
  
  puts "  Checking if record exists..."
  exists = dns_service.get_dns_record_id(test_subdomain)
  puts "  #{exists ? '✅ Record found' : '❌ Record not found'}"
  
  puts "  Deleting DNS record..."
  delete_result = dns_service.delete_subdomain(test_subdomain)
  if delete_result[:success]
    puts "  ✅ DNS record deleted successfully"
  else
    puts "  ❌ Failed to delete DNS record: #{delete_result[:error]}"
  end
else
  puts "  ❌ Failed to create DNS record: #{result[:error]}"
end

puts "\n3. Testing with existing tenant subdomains:"
Tenant.all.each do |tenant|
  available = dns_service.subdomain_available?(tenant.subdomain)
  puts "  #{tenant.subdomain}: #{available ? '✅ Available' : '❌ Not available (expected for existing tenants)'}"
end

puts "\n=== Test Complete ==="
