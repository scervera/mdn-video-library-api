namespace :email do
  desc "Test Brevo email configuration"
  task test: :environment do
    puts "🧪 Testing Brevo Email Configuration..."
    
    # Get test email from command line or use default
    test_email = ENV['TEST_EMAIL'] || 'test@example.com'
    
    puts "📧 Sending test email to: #{test_email}"
    
    begin
      TestMailer.test_email(test_email).deliver_now
      puts "✅ Test email sent successfully!"
      puts "📋 Check your email inbox for the test message."
    rescue => e
      puts "❌ Failed to send test email:"
      puts "   Error: #{e.message}"
      puts "   Backtrace: #{e.backtrace.first(3).join("\n   ")}"
      puts ""
      puts "🔧 Troubleshooting:"
      puts "   1. Check your Brevo credentials in .env file"
      puts "   2. Verify BREVO_SMTP_USERNAME and BREVO_SMTP_PASSWORD are correct"
      puts "   3. Ensure your Brevo account is active and has SMTP access"
    end
  end

  desc "Test user invitation email"
  task test_invitation: :environment do
    puts "🧪 Testing User Invitation Email..."
    
    # Get test email from command line or use default
    test_email = ENV['TEST_EMAIL'] || 'test@example.com'
    
    # Find or create a test invitation
    tenant = Tenant.first
    if tenant.nil?
      puts "❌ No tenants found. Please run 'bin/rails db:seed' first."
      exit 1
    end
    
    user = tenant.users.first
    if user.nil?
      puts "❌ No users found. Please run 'bin/rails db:seed' first."
      exit 1
    end
    
    # Create a test invitation
    invitation = tenant.user_invitations.create!(
      email: test_email,
      invited_by: user,
      message: "This is a test invitation email."
    )
    
    puts "📧 Sending test invitation email to: #{test_email}"
    
    begin
      UserInvitationMailer.invitation_email(invitation).deliver_now
      puts "✅ Test invitation email sent successfully!"
      puts "📋 Check your email inbox for the invitation message."
      
      # Clean up test invitation
      invitation.destroy
      puts "🧹 Cleaned up test invitation."
    rescue => e
      puts "❌ Failed to send test invitation email:"
      puts "   Error: #{e.message}"
      puts "   Backtrace: #{e.backtrace.first(3).join("\n   ")}"
    end
  end
end
