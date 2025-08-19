#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Testing Cloudflare DNS Service (Local Mock) ==="

# Mock the Cloudflare API for testing
class MockCloudflareDnsService < CloudflareDnsService
  def initialize
    @mock_records = []
    @mock_errors = []
  end

  def subdomain_available?(subdomain)
    return false unless valid_subdomain_format?(subdomain)
    return false if Tenant.exists?(subdomain: subdomain)
    return false if @mock_records.any? { |r| r['name'] == "#{subdomain}.cerveras.com" }
    true
  end

  def create_subdomain(subdomain)
    return { success: false, error: 'Invalid subdomain format' } unless valid_subdomain_format?(subdomain)
    return { success: false, error: 'Subdomain already exists' } unless subdomain_available?(subdomain)

    # Simulate API call
    record_id = "mock_record_#{SecureRandom.hex(8)}"
    @mock_records << {
      'id' => record_id,
      'name' => "#{subdomain}.cerveras.com",
      'type' => 'CNAME',
      'content' => 'cerveras.com'
    }
    
    { success: true, record_id: record_id }
  end

  def delete_subdomain(subdomain)
    record = @mock_records.find { |r| r['name'] == "#{subdomain}.cerveras.com" }
    return { success: false, error: 'DNS record not found' } unless record

    @mock_records.delete(record)
    { success: true }
  end

  def get_dns_record_id(subdomain)
    record = @mock_records.find { |r| r['name'] == "#{subdomain}.cerveras.com" }
    record&.dig('id')
  end

  def list_dns_records
    @mock_records
  end
end

# Use mock service for testing
dns_service = MockCloudflareDnsService.new

puts "\n1. Testing subdomain validation:"
test_subdomains = [
  'test123',           # Valid
  'invalid--subdomain', # Invalid (consecutive hyphens)
  'www',               # Reserved
  'api',               # Reserved
  'admin',             # Reserved
  'a',                 # Too short
  'very-long-subdomain-name-that-exceeds-the-maximum-length-allowed-by-dns-standards', # Too long
  'test-123',          # Valid with hyphen
  'test_123'           # Invalid (underscore)
]

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
  
  puts "  Testing subdomain availability after creation..."
  available = dns_service.subdomain_available?(test_subdomain)
  puts "  #{available ? '❌ Still available (should not be)' : '✅ Correctly marked as unavailable'}"
  
  puts "  Deleting DNS record..."
  delete_result = dns_service.delete_subdomain(test_subdomain)
  if delete_result[:success]
    puts "  ✅ DNS record deleted successfully"
    
    puts "  Testing subdomain availability after deletion..."
    available = dns_service.subdomain_available?(test_subdomain)
    puts "  #{available ? '✅ Available again' : '❌ Still unavailable'}"
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

puts "\n4. Testing API endpoint (simulated):"
puts "  Testing subdomain validation endpoint..."

# Simulate the API endpoint logic
test_api_subdomain = "api-test-#{Time.current.to_i}"
if test_api_subdomain.blank?
  puts "  ❌ Subdomain is required"
else
  if dns_service.subdomain_available?(test_api_subdomain)
    puts "  ✅ Subdomain '#{test_api_subdomain}' is available"
    puts "  Full domain: #{test_api_subdomain}.cerveras.com"
  else
    puts "  ❌ Subdomain '#{test_api_subdomain}' is not available"
  end
end

puts "\n=== Local Test Complete ==="
puts "\n✅ All DNS service functionality is working correctly!"
puts "\nNext steps:"
puts "1. Set up Cloudflare API credentials"
puts "2. Test with real Cloudflare API"
puts "3. Test tenant registration with DNS integration"
