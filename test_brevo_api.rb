#!/usr/bin/env ruby

require 'net/http'
require 'json'

# Get API key from environment
api_key = ENV['BREVO_API_KEY']

if api_key.nil?
  puts "❌ BREVO_API_KEY not found in environment"
  exit 1
end

puts "🔑 Testing Brevo API Key: #{api_key[0..20]}..."
puts ""

# Test 1: Get account information
puts "📊 Testing API key with account info..."
uri = URI('https://api.brevo.com/v3/account')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['api-key'] = api_key
request['Content-Type'] = 'application/json'

begin
  response = http.request(request)
  
  if response.code == '200'
    puts "✅ API key is valid!"
    account_info = JSON.parse(response.body)
    puts "   Account: #{account_info['email']}"
    puts "   Plan: #{account_info['plan']}"
  else
    puts "❌ API key test failed:"
    puts "   Status: #{response.code}"
    puts "   Body: #{response.body}"
  end
rescue => e
  puts "❌ Error testing API key: #{e.message}"
end

puts ""

# Test 2: Get sender information
puts "📧 Testing sender information..."
uri = URI('https://api.brevo.com/v3/senders')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['api-key'] = api_key
request['Content-Type'] = 'application/json'

begin
  response = http.request(request)
  
  if response.code == '200'
    puts "✅ Sender info retrieved successfully!"
    senders = JSON.parse(response.body)
    puts "   Available senders: #{senders['senders'].map { |s| s['email'] }.join(', ')}"
  else
    puts "❌ Sender info test failed:"
    puts "   Status: #{response.code}"
    puts "   Body: #{response.body}"
  end
rescue => e
  puts "❌ Error testing sender info: #{e.message}"
end
