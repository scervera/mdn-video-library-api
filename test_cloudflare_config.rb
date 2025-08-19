#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Testing Cloudflare Configuration ==="

begin
  # Test configuration loading
  puts "\n1. Testing configuration loading..."
  config = Rails.application.config_for(:cloudflare)
  puts "  ✅ Configuration loaded successfully"
  puts "  Domain: #{config[:domain]}"
  puts "  API Token: #{config[:api_token] ? '✅ Set' : '❌ Not set'}"
  puts "  Zone ID: #{config[:zone_id] ? '✅ Set' : '❌ Not set'}"

  # Test DNS service initialization
  puts "\n2. Testing DNS service initialization..."
  dns_service = CloudflareDnsService.new
  puts "  ✅ DNS service initialized successfully"
  puts "  API Token: #{dns_service.instance_variable_get(:@api_token) ? '✅ Available' : '❌ Missing'}"
  puts "  Zone ID: #{dns_service.instance_variable_get(:@zone_id) ? '✅ Available' : '❌ Missing'}"
  puts "  Domain: #{dns_service.instance_variable_get(:@domain)}"

  # Test subdomain validation
  puts "\n3. Testing subdomain validation..."
  test_subdomain = "test-#{Time.current.to_i}"
  available = dns_service.subdomain_available?(test_subdomain)
  puts "  Subdomain '#{test_subdomain}': #{available ? '✅ Available' : '❌ Not available'}"

  # Test API endpoint
  puts "\n4. Testing API endpoint..."
  puts "  Starting server test..."
  
  # Start server in background
  server_pid = Process.spawn("bin/rails server -p 3001 -d")
  sleep 5
  
  # Test the endpoint
  require 'net/http'
  uri = URI('http://localhost:3001/api/v1/subdomain_validation/check?subdomain=test123')
  response = Net::HTTP.get_response(uri)
  
  if response.code == '200'
    puts "  ✅ API endpoint working"
    puts "  Response: #{response.body}"
  else
    puts "  ❌ API endpoint failed: #{response.code}"
    puts "  Response: #{response.body}"
  end
  
  # Stop server
  Process.kill('TERM', server_pid) if server_pid
  Process.wait(server_pid) if server_pid

rescue => e
  puts "  ❌ Error: #{e.message}"
  puts "  Backtrace: #{e.backtrace.first(3).join("\n    ")}"
end

puts "\n=== Configuration Test Complete ==="
puts ""
puts "If you see ❌ for API Token or Zone ID, run:"
puts "  ./setup_cloudflare_env.sh"
puts ""
puts "For production deployment:"
puts "  kamal secrets set CLOUDFLARE_API_TOKEN=your_token"
puts "  kamal secrets set CLOUDFLARE_ZONE_ID=your_zone_id"
