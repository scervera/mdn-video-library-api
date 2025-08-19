#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# Load Cloudflare configuration
config = Rails.application.config_for(:cloudflare)

if config.nil? || config[:dns_api_token].blank?
  puts "❌ Cloudflare configuration not found or incomplete."
  puts "Please run: ./setup_cloudflare_env.sh"
  exit 1
end

api_token = config[:dns_api_token]
zone_id = config[:zone_id]
domain = config[:domain] || 'cerveras.com'

puts "🔍 Verifying Cloudflare configuration..."
puts "🌐 Domain: #{domain}"
puts "🔑 Zone ID: #{zone_id}"
puts ""

# First, let's list all zones to verify the Zone ID
puts "📋 Listing available zones..."

uri = URI("https://api.cloudflare.com/client/v4/zones")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{api_token}"
request['Content-Type'] = 'application/json'

response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  if result['success']
    puts "✅ Found #{result['result'].length} zones:"
    result['result'].each do |zone|
      puts "  - #{zone['name']} (ID: #{zone['id']})"
      if zone['name'] == domain
        puts "    ✅ This matches your configured domain!"
        if zone['id'] == zone_id
          puts "    ✅ Zone ID matches configuration!"
        else
          puts "    ❌ Zone ID mismatch! Expected: #{zone_id}, Found: #{zone['id']}"
        end
      end
    end
  else
    puts "❌ Failed to list zones:"
    puts result['errors'].inspect
  end
else
  puts "❌ HTTP Error: #{response.code}"
  puts "Response: #{response.body}"
end

puts ""
puts "🔍 Testing specific zone access..."

# Now test the specific zone
uri = URI("https://api.cloudflare.com/client/v4/zones/#{zone_id}")
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{api_token}"
request['Content-Type'] = 'application/json'

response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  if result['success']
    zone = result['result']
    puts "✅ Zone access successful!"
    puts "🌐 Zone name: #{zone['name']}"
    puts "🆔 Zone ID: #{zone['id']}"
    puts "📊 Status: #{zone['status']}"
  else
    puts "❌ Zone access failed:"
    puts result['errors'].inspect
  end
else
  puts "❌ HTTP Error: #{response.code}"
  puts "Response: #{response.body}"
end
