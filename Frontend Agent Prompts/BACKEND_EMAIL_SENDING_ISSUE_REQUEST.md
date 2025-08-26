# Backend Agent Request: Fix Email Sending for User Invitations

## 🚨 **Issue Summary**

The user invitation system is partially working - invitations are being created successfully in the database and appear as "pending" in the UI, but **the actual invitation emails are not being sent** to users. This means users never receive the invitation emails and cannot accept them.

## ✅ **What's Working**

1. **Invitation Creation**: `POST /api/v1/users/invite` creates invitation records successfully
2. **Database Storage**: Invitations are saved with correct status, tokens, and metadata
3. **Frontend Integration**: UI shows pending invitations correctly
4. **API Responses**: All endpoints return proper data

## ❌ **What's Not Working**

1. **Email Delivery**: Invitation emails are not being sent to users
2. **Email Configuration**: ActionMailer may not be properly configured
3. **Email Templates**: Invitation email templates may be missing or misconfigured

## 🔍 **Evidence**

### **Successful Invitation Creation**
```bash
curl -X POST "https://curriculum-library-api.cerveras.com/api/v1/users/invite" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "X-Tenant: acme1" \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser123@example.com","role":"user","message":"Test invitation"}'
```

**Response**: `201 Created`
```json
{
  "invitation": {
    "id": 3,
    "email": "newuser123@example.com",
    "status": "pending",
    "token": "IB7ZX05TEk-CBTrX5AOiwEUyIDDkQVMxADa_NkR_iJE",
    "expires_at": "2025-09-05T23:38:08.967Z",
    "created_at": "2025-08-22T23:38:08.971Z"
  }
}
```

### **Email Not Received**
- Users report not receiving invitation emails
- No email delivery confirmation in logs
- Invitations remain "pending" indefinitely

## 🛠️ **Required Investigation & Fixes**

### 1. **Check ActionMailer Configuration**
```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

### 2. **Verify Email Templates**
```erb
<!-- app/views/user_invitation_mailer/invite.html.erb -->
<h1>You're invited to join <%= @invitation.tenant.name %></h1>
<p>Hello!</p>
<p>You've been invited to join <%= @invitation.tenant.name %> as a <%= @invitation.role %>.</p>
<% if @invitation.message.present? %>
  <p>Message: <%= @invitation.message %></p>
<% end %>
<p>Click the link below to accept the invitation:</p>
<a href="<%= accept_invitation_url(@invitation.token) %>">Accept Invitation</a>
<p>This invitation expires on <%= @invitation.expires_at.strftime('%B %d, %Y') %>.</p>
```

### 3. **Check Mailer Implementation**
```ruby
# app/mailers/user_invitation_mailer.rb
class UserInvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @tenant = invitation.tenant
    
    mail(
      to: invitation.email,
      subject: "You're invited to join #{@tenant.name}",
      from: ENV['FROM_EMAIL'] || 'noreply@yourdomain.com'
    )
  end
end
```

### 4. **Verify Controller Email Sending**
```ruby
# app/controllers/api/v1/users_controller.rb
def invite
  invitation = current_tenant.user_invitations.build(invitation_params)
  invitation.invited_by = current_user
  
  if invitation.save
    # Make sure this line is present and working
    UserInvitationMailer.invite(invitation).deliver_later
    
    render json: { invitation: invitation }, status: :created
  else
    render json: { error: invitation.errors }, status: :unprocessable_entity
  end
end
```

## 🔧 **Environment Variables to Check**

Ensure these environment variables are set in production:

```bash
# SMTP Configuration
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Email Configuration
FROM_EMAIL=noreply@yourdomain.com
DEFAULT_URL_HOST=https://curriculum.cerveras.com

# Background Job Configuration (if using deliver_later)
REDIS_URL=redis://localhost:6379
```

## 🧪 **Testing Steps**

### 1. **Test Email Configuration**
```ruby
# In Rails console
ActionMailer::Base.delivery_method = :test
ActionMailer::Base.deliveries.clear

# Test sending an email
invitation = UserInvitation.find(3)
UserInvitationMailer.invite(invitation).deliver_now

# Check if email was queued
puts ActionMailer::Base.deliveries.count
puts ActionMailer::Base.deliveries.first
```

### 2. **Test SMTP Connection**
```ruby
# In Rails console
require 'net/smtp'

smtp = Net::SMTP.new(ENV['SMTP_ADDRESS'], ENV['SMTP_PORT'])
smtp.enable_starttls_auto
smtp.start(ENV['SMTP_DOMAIN'], ENV['SMTP_USERNAME'], ENV['SMTP_PASSWORD'], :plain) do |smtp|
  puts "SMTP connection successful"
end
```

### 3. **Check Background Jobs**
```ruby
# If using deliver_later, check job queue
Sidekiq::Queue.new.size  # Should show pending jobs
Sidekiq::RetrySet.new.size  # Should show failed jobs
```

## 📋 **Common Issues & Solutions**

### 1. **SMTP Configuration**
- **Issue**: Wrong SMTP settings
- **Solution**: Verify SMTP credentials and settings

### 2. **Email Templates Missing**
- **Issue**: Mailer templates not found
- **Solution**: Create proper ERB templates

### 3. **Background Jobs Not Processing**
- **Issue**: `deliver_later` jobs stuck in queue
- **Solution**: Check Sidekiq/Redis configuration

### 4. **Environment Variables**
- **Issue**: Missing or incorrect env vars
- **Solution**: Verify all required env vars are set

### 5. **Email Provider Limits**
- **Issue**: Gmail/SMTP provider blocking emails
- **Solution**: Check email provider settings and limits

## 🎯 **Success Criteria**

The email sending is fixed when:

1. ✅ Invitation emails are actually delivered to users
2. ✅ Users can click the invitation link and accept invitations
3. ✅ Invitation status changes from "pending" to "accepted" when used
4. ✅ Email delivery is logged and trackable
5. ✅ No errors in email sending process

## 📞 **Next Steps**

1. **Backend Team**: Investigate ActionMailer configuration and email templates
2. **Testing**: Verify email delivery with test invitations
3. **Monitoring**: Add email delivery logging and monitoring
4. **Documentation**: Update email configuration documentation

---

**Priority**: High - This blocks the core user invitation functionality  
**Impact**: Users cannot be invited to the platform  
**Estimated Effort**: 2-4 hours for investigation and fix
