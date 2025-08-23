#!/bin/bash

# Setup Brevo Environment Variables
# This script helps you configure Brevo email service SMTP credentials

echo "🚀 Setting up Brevo Email Service Configuration (SMTP)"
echo "======================================================"

# Detect shell
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
    if [ ! -f "$SHELL_PROFILE" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    fi
else
    SHELL_PROFILE="$HOME/.profile"
fi

echo "📧 Brevo SMTP Configuration Setup"
echo ""
echo "You'll need to get your SMTP credentials from the Brevo dashboard:"
echo "1. Go to https://app.brevo.com/"
echo "2. Navigate to Settings → SMTP & API"
echo "3. In the SMTP section, find your SMTP Username and Password"
echo ""

# Get Brevo SMTP Username
echo "Enter your Brevo SMTP Username (usually your Brevo account email):"
read BREVO_SMTP_USERNAME

# Get Brevo SMTP Password
echo "Enter your Brevo SMTP Password:"
read -s BREVO_SMTP_PASSWORD

# Get From Email (optional)
echo "Enter your From Email address (default: noreply@cerveras.com):"
read BREVO_FROM_EMAIL
BREVO_FROM_EMAIL=${BREVO_FROM_EMAIL:-noreply@cerveras.com}

# Get From Name (optional)
echo "Enter your From Name (default: Curriculum Library):"
read BREVO_FROM_NAME
BREVO_FROM_NAME=${BREVO_FROM_NAME:-Curriculum Library}

echo ""
echo "🔧 Setting up environment variables..."

# Create .env file for local development
cat > .env << EOF
# Brevo Email Service Configuration (SMTP)
BREVO_SMTP_USERNAME=$BREVO_SMTP_USERNAME
BREVO_SMTP_PASSWORD=$BREVO_SMTP_PASSWORD
BREVO_FROM_EMAIL=$BREVO_FROM_EMAIL
BREVO_FROM_NAME=$BREVO_FROM_NAME

# Additional environment variables for local development
CLOUDFLARE_DOMAIN=cerveras.com
CLOUDFLARE_DNS_API_TOKEN=your_dns_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
CLOUDFLARE_STREAM_API_TOKEN=your_stream_api_token_here
CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id_here
EOF

echo "✅ Created .env file with Brevo SMTP configuration"

# Add to shell profile for persistent environment variables
echo ""
echo "Do you want to add these environment variables to your shell profile ($SHELL_PROFILE)? (y/n)"
read -r ADD_TO_PROFILE

if [[ $ADD_TO_PROFILE =~ ^[Yy]$ ]]; then
    echo "" >> "$SHELL_PROFILE"
    echo "# Brevo Email Service Configuration (SMTP)" >> "$SHELL_PROFILE"
    echo "export BREVO_SMTP_USERNAME=$BREVO_SMTP_USERNAME" >> "$SHELL_PROFILE"
    echo "export BREVO_SMTP_PASSWORD=$BREVO_SMTP_PASSWORD" >> "$SHELL_PROFILE"
    echo "export BREVO_FROM_EMAIL=$BREVO_FROM_EMAIL" >> "$SHELL_PROFILE"
    echo "export BREVO_FROM_NAME=$BREVO_FROM_NAME" >> "$SHELL_PROFILE"
    echo "" >> "$SHELL_PROFILE"
    echo "# Cloudflare Configuration (update with your actual values)" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_DOMAIN=cerveras.com" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_DNS_API_TOKEN=your_dns_api_token_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_ZONE_ID=your_zone_id_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_STREAM_API_TOKEN=your_stream_api_token_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id_here" >> "$SHELL_PROFILE"
    
    echo "✅ Added Brevo SMTP environment variables to $SHELL_PROFILE"
    echo "🔄 Please run 'source $SHELL_PROFILE' or restart your terminal to load the new environment variables"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Set up Kamal secrets for production:"
echo "   kamal secrets set BREVO_SMTP_USERNAME=$BREVO_SMTP_USERNAME"
echo "   kamal secrets set BREVO_SMTP_PASSWORD=$BREVO_SMTP_PASSWORD"
echo ""
echo "2. Test the email configuration:"
echo "   bin/rails console"
echo "   UserInvitationMailer.invitation_email(UserInvitation.first).deliver_now"
echo ""
echo "3. Deploy to production:"
echo "   kamal deploy"
echo ""
echo "🎉 Brevo SMTP email service configuration complete!"
echo ""
echo "💡 Note: This configuration uses SMTP instead of the HTTP API for better reliability."
