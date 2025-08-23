#!/usr/bin/env ruby

require 'net/smtp'

# Get SMTP credentials from environment
smtp_username = ENV['BREVO_SMTP_USERNAME']
smtp_password = ENV['BREVO_SMTP_PASSWORD']

puts "🔍 Testing Brevo SMTP Configuration"
puts "=================================="
puts "SMTP Username: #{smtp_username || 'NOT SET'}"
puts "SMTP Password: #{smtp_password ? 'SET' : 'NOT SET'}"
puts ""

if smtp_username.nil? || smtp_password.nil?
  puts "❌ SMTP credentials not found in environment"
  puts "Please set BREVO_SMTP_USERNAME and BREVO_SMTP_PASSWORD"
  exit 1
end

# Test SMTP connection
puts "📧 Testing SMTP connection..."
begin
  smtp = Net::SMTP.new('smtp-relay.brevo.com', 587)
  smtp.enable_starttls_auto
  
  puts "Connecting to smtp-relay.brevo.com:587..."
  smtp.start('cerveras.com', smtp_username, smtp_password, :plain) do |smtp|
    puts "✅ SMTP connection successful!"
    puts "   Server: smtp-relay.brevo.com"
    puts "   Port: 587"
    puts "   Username: #{smtp_username}"
    puts "   Authentication: PLAIN"
  end
rescue => e
  puts "❌ SMTP connection failed:"
  puts "   Error: #{e.message}"
  puts "   Error class: #{e.class}"
  puts ""
  puts "🔧 Troubleshooting Tips:"
  puts "1. Verify SMTP username and password are correct"
  puts "2. Check if SMTP access is enabled in your Brevo account"
  puts "3. Ensure your Brevo account is active"
  puts "4. Try generating new SMTP credentials from Brevo dashboard"
end

puts ""
puts "🧪 To test email sending, run:"
puts "   bin/rails console"
puts "   UserInvitationMailer.invitation_email(UserInvitation.first).deliver_now"
