#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# Load Cloudflare configuration
config = Rails.application.config_for(:cloudflare)

if config.nil? || config[:dns_api_token].blank? || config[:zone_id].blank?
  puts "❌ Cloudflare configuration not found or incomplete."
  puts "Please run: ./setup_cloudflare_env.sh"
  exit 1
end

# Cloudflare API configuration
api_token = config[:dns_api_token]
zone_id = config[:zone_id]
domain = config[:domain] || 'cerveras.com'

# DNS record details
record_name = 'curriculum-library-api'
record_type = 'CNAME'
record_content = 'cloud.cerveras.com'
proxy_status = false  # DNS only, not proxied

puts "🌐 Adding DNS record for #{record_name}.#{domain}..."
puts "📝 Record type: #{record_type}"
puts "🎯 Target: #{record_content}"
puts "🔒 Proxy status: #{proxy_status ? 'Proxied' : 'DNS only'}"

# Prepare the request
uri = URI("https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Authorization'] = "Bearer #{api_token}"
request['Content-Type'] = 'application/json'

# DNS record data
dns_data = {
  type: record_type,
  name: record_name,
  content: record_content,
  proxied: proxy_status,
  ttl: 1  # Auto TTL
}

request.body = dns_data.to_json

# Make the request
response = http.request(request)

if response.code == '200'
  result = JSON.parse(response.body)
  if result['success']
    puts "✅ DNS record created successfully!"
    puts "📋 Record ID: #{result['result']['id']}"
    puts "🔗 Full domain: #{record_name}.#{domain}"
    puts ""
    puts "⏳ DNS propagation may take a few minutes..."
    puts "🧪 Test with: nslookup #{record_name}.#{domain}"
  else
    puts "❌ Failed to create DNS record:"
    puts result['errors'].inspect
  end
elsif response.code == '400'
  result = JSON.parse(response.body)
  if result['errors']&.any? { |error| error['code'] == 81057 }
    puts "⚠️  DNS record already exists!"
    puts "✅ The record should be working now."
  else
    puts "❌ Failed to create DNS record:"
    puts result['errors'].inspect
  end
else
  puts "❌ HTTP Error: #{response.code}"
  puts "Response: #{response.body}"
end
