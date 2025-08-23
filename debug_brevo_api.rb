#!/usr/bin/env ruby

require 'net/http'
require 'json'

# Get API key from environment
api_key = ENV['BREVO_API_KEY']

puts "🔍 Debugging Brevo API Key"
puts "=========================="
puts "API Key length: #{api_key ? api_key.length : 0}"
puts "API Key starts with: #{api_key ? api_key[0..20] : 'nil'}..."
puts "API Key ends with: #{api_key ? api_key[-20..-1] : 'nil'}"
puts ""

if api_key.nil?
  puts "❌ BREVO_API_KEY is nil"
  exit 1
end

if api_key.empty?
  puts "❌ BREVO_API_KEY is empty"
  exit 1
end

# Test 1: Simple account info request
puts "📊 Testing API key with account info..."
uri = URI('https://api.brevo.com/v3/account')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['api-key'] = api_key
request['Content-Type'] = 'application/json'

puts "Request headers:"
puts "  api-key: #{api_key[0..20]}..."
puts "  Content-Type: #{request['Content-Type']}"
puts ""

begin
  response = http.request(request)
  
  puts "Response:"
  puts "  Status: #{response.code}"
  puts "  Body: #{response.body}"
  puts ""
  
  if response.code == '200'
    puts "✅ API key is valid!"
    account_info = JSON.parse(response.body)
    puts "   Account: #{account_info['email']}"
    puts "   Plan: #{account_info['plan']}"
  else
    puts "❌ API key test failed"
  end
rescue => e
  puts "❌ Error testing API key: #{e.message}"
  puts "   Error class: #{e.class}"
end

puts ""
puts "🔧 Troubleshooting Tips:"
puts "1. Make sure the API key is correct and not expired"
puts "2. Check if the API key has the right permissions"
puts "3. Verify the API key is from the correct Brevo account"
puts "4. Try generating a new API key from the Brevo dashboard"
