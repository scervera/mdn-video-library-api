# Brevo Email Service Setup

This document explains how to set up and configure Brevo (formerly Sendinblue) for transactional emails in the Curriculum Library API.

## 🎯 Overview

Brevo is used for sending transactional emails such as:
- User invitation emails
- Invitation reminders
- Password reset emails (future)
- Account confirmation emails (future)

## 📋 Prerequisites

1. **Brevo Account**: Sign up at [brevo.com](https://brevo.com)
2. **SMTP Access**: Ensure your Brevo account has SMTP access enabled
3. **API Key**: Generate an API key from your Brevo dashboard
4. **SMTP Credentials**: Get your SMTP username and password

## 🔧 Setup Instructions

### 1. Get Brevo Credentials

1. Log into your [Brevo Dashboard](https://app.brevo.com/)
2. Go to **Settings** → **SMTP & API**
3. Note down your:
   - **API Key**
   - **SMTP Username** (usually your Brevo account email)
   - **SMTP Password**

### 2. Configure Environment Variables

#### Option A: Use the Setup Script (Recommended)

```bash
./setup_brevo_env.sh
```

This script will:
- Prompt for your Brevo credentials
- Create a `.env` file for local development
- Optionally add environment variables to your shell profile
- Provide next steps for production deployment

#### Option B: Manual Setup

Create a `.env` file in the project root:

```bash
# Brevo Email Service Configuration
BREVO_API_KEY=your_api_key_here
BREVO_SMTP_USERNAME=your_smtp_username
BREVO_SMTP_PASSWORD=your_smtp_password
BREVO_FROM_EMAIL=noreply@cerveras.com
BREVO_FROM_NAME=Curriculum Library
```

### 3. Test the Configuration

#### Test Basic Email Functionality

```bash
# Test with a specific email
TEST_EMAIL=your-email@example.com bin/rails email:test

# Test with default email
bin/rails email:test
```

#### Test User Invitation Email

```bash
# Test invitation email with a specific email
TEST_EMAIL=your-email@example.com bin/rails email:test_invitation

# Test invitation email with default email
bin/rails email:test_invitation
```

### 4. Production Deployment

#### Set Kamal Secrets

```bash
# Set Brevo credentials in production
kamal secrets set BREVO_API_KEY=your_api_key_here
kamal secrets set BREVO_SMTP_USERNAME=your_smtp_username
kamal secrets set BREVO_SMTP_PASSWORD=your_smtp_password
```

#### Deploy to Production

```bash
kamal deploy
```

## 📧 Email Templates

### User Invitation Email

**Template**: `app/views/user_invitation_mailer/invitation_email.html.erb`
**Text Version**: `app/views/user_invitation_mailer/invitation_email.text.erb`

**Features**:
- Professional HTML design with responsive layout
- Organization and role information
- Personal message from inviter (if provided)
- Clear call-to-action button
- Expiration warning
- Plain text fallback

### Invitation Reminder Email

**Template**: `app/views/user_invitation_mailer/invitation_reminder.html.erb`
**Text Version**: `app/views/user_invitation_mailer/invitation_reminder.text.erb`

**Features**:
- Urgent styling for time-sensitive reminders
- Same information as invitation email
- Emphasized expiration warning
- Clear call-to-action

## 🔄 Email Workflow

### User Invitation Process

1. **Admin creates invitation** via API
2. **User and invitation records** are created in database
3. **Invitation email** is sent automatically via background job
4. **User clicks link** in email to accept invitation
5. **Frontend validates token** and activates user account
6. **Optional reminder emails** can be sent if invitation expires

### Email Sending

- **Background Jobs**: Emails are sent using `deliver_later` for better performance
- **Error Handling**: Failed emails are logged and can be retried
- **Rate Limiting**: Brevo handles rate limiting automatically

## 🛠️ Configuration Files

### Main Configuration

- **`config/brevo.yml`**: Brevo service configuration
- **`config/environments/development.rb`**: Development email settings
- **`config/environments/production.rb`**: Production email settings
- **`config/deploy.yml`**: Kamal deployment configuration

### Mailer Classes

- **`app/mailers/application_mailer.rb`**: Base mailer with Brevo configuration
- **`app/mailers/user_invitation_mailer.rb`**: User invitation emails
- **`app/mailers/test_mailer.rb`**: Test emails for configuration verification

## 🧪 Testing

### Local Testing

```bash
# Start Rails console
bin/rails console

# Test basic email
TestMailer.test_email('test@example.com').deliver_now

# Test invitation email
invitation = UserInvitation.first
UserInvitationMailer.invitation_email(invitation).deliver_now
```

### Production Testing

```bash
# Test via Rails task
kamal app exec "bin/rails email:test TEST_EMAIL=your-email@example.com"
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify SMTP username and password
   - Check if SMTP access is enabled in Brevo
   - Ensure API key is valid

2. **Emails Not Sending**
   - Check Rails logs for error messages
   - Verify environment variables are set correctly
   - Test with `bin/rails email:test`

3. **Emails Going to Spam**
   - Configure proper SPF/DKIM records
   - Use consistent from address
   - Monitor Brevo deliverability metrics

### Debug Commands

```bash
# Check environment variables
echo $BREVO_SMTP_USERNAME
echo $BREVO_SMTP_PASSWORD

# Test SMTP connection
telnet smtp-relay.brevo.com 587

# Check Rails mailer configuration
bin/rails console
Rails.application.config.action_mailer.smtp_settings
```

## 📊 Monitoring

### Brevo Dashboard

Monitor email performance in your Brevo dashboard:
- **Delivery Rates**: Track successful vs failed deliveries
- **Open Rates**: Monitor email engagement
- **Bounce Rates**: Identify invalid email addresses
- **Spam Reports**: Monitor reputation

### Application Logs

```bash
# View application logs
kamal app logs

# Filter for email-related logs
kamal app logs | grep -i mail
```

## 🔐 Security Considerations

1. **Environment Variables**: Never commit credentials to version control
2. **API Key Security**: Rotate API keys regularly
3. **SMTP Security**: Use TLS encryption (enabled by default)
4. **Rate Limiting**: Respect Brevo's rate limits
5. **Data Privacy**: Ensure compliance with email regulations

## 📈 Performance Optimization

1. **Background Jobs**: Use `deliver_later` for non-blocking email sending
2. **Template Caching**: Email templates are cached in production
3. **Batch Processing**: Consider batching multiple emails
4. **Monitoring**: Track email queue performance

## 🔄 Future Enhancements

- **Email Templates**: Add more email types (password reset, account confirmation)
- **Email Preferences**: Allow users to manage email preferences
- **Analytics**: Track email engagement and conversion rates
- **A/B Testing**: Test different email templates and content
- **Automation**: Set up automated email sequences

---

For more information, visit the [Brevo Documentation](https://developers.brevo.com/).
