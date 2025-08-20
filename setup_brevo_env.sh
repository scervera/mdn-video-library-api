#!/bin/bash

# Setup Brevo Environment Variables
# This script helps you configure Brevo email service environment variables

echo "🚀 Setting up Brevo Email Service Configuration"
echo "================================================"

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

echo "📧 Brevo Configuration Setup"
echo ""

# Get Brevo API Key
echo "Enter your Brevo API Key:"
read -s BREVO_API_KEY

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
# Brevo Email Service Configuration
BREVO_API_KEY=$BREVO_API_KEY
BREVO_FROM_EMAIL=$BREVO_FROM_EMAIL
BREVO_FROM_NAME=$BREVO_FROM_NAME

# Additional environment variables for local development
CLOUDFLARE_DOMAIN=cerveras.com
CLOUDFLARE_DNS_API_TOKEN=your_dns_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
CLOUDFLARE_STREAM_API_TOKEN=your_stream_api_token_here
CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id_here
EOF

echo "✅ Created .env file with Brevo configuration"

# Add to shell profile for persistent environment variables
echo ""
echo "Do you want to add these environment variables to your shell profile ($SHELL_PROFILE)? (y/n)"
read -r ADD_TO_PROFILE

if [[ $ADD_TO_PROFILE =~ ^[Yy]$ ]]; then
    echo "" >> "$SHELL_PROFILE"
    echo "# Brevo Email Service Configuration" >> "$SHELL_PROFILE"
    echo "export BREVO_API_KEY=$BREVO_API_KEY" >> "$SHELL_PROFILE"
    echo "export BREVO_FROM_EMAIL=$BREVO_FROM_EMAIL" >> "$SHELL_PROFILE"
    echo "export BREVO_FROM_NAME=$BREVO_FROM_NAME" >> "$SHELL_PROFILE"
    echo "" >> "$SHELL_PROFILE"
    echo "# Cloudflare Configuration (update with your actual values)" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_DOMAIN=cerveras.com" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_DNS_API_TOKEN=your_dns_api_token_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_ZONE_ID=your_zone_id_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_STREAM_API_TOKEN=your_stream_api_token_here" >> "$SHELL_PROFILE"
    echo "export CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id_here" >> "$SHELL_PROFILE"
    
    echo "✅ Added Brevo environment variables to $SHELL_PROFILE"
    echo "🔄 Please run 'source $SHELL_PROFILE' or restart your terminal to load the new environment variables"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Set up Kamal secrets for production:"
echo "   kamal secrets set BREVO_API_KEY=$BREVO_API_KEY"
echo ""
echo "2. Test the email configuration:"
echo "   bin/rails console"
echo "   UserInvitationMailer.invitation_email(UserInvitation.first).deliver_now"
echo ""
echo "3. Deploy to production:"
echo "   kamal deploy"
echo ""
echo "🎉 Brevo email service configuration complete!"
