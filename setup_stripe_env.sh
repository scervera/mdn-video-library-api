#!/bin/bash

echo "🔧 Setting up Stripe Environment Variables"
echo "=========================================="
echo ""

# Check if Stripe CLI is logged in
if ! stripe config --list > /dev/null 2>&1; then
    echo "❌ Stripe CLI not logged in. Please run: stripe login"
    exit 1
fi

echo "✅ Stripe CLI is logged in"
echo ""

# Get Stripe keys from CLI
echo "📋 Getting Stripe keys from CLI..."
STRIPE_SECRET_KEY=$(stripe config --list | grep "test_mode_api_key" | cut -d"'" -f2)
STRIPE_PUBLISHABLE_KEY=$(stripe config --list | grep "test_mode_pub_key" | cut -d"'" -f2)

echo "🔑 Stripe Secret Key: ${STRIPE_SECRET_KEY:0:20}..."
echo "🔑 Stripe Publishable Key: ${STRIPE_PUBLISHABLE_KEY:0:20}..."
echo ""

# Ask if user wants to set environment variables
echo "Do you want to set these as environment variables on your dev machine? (y/n)"
read -r ADD_TO_PROFILE

if [[ $ADD_TO_PROFILE =~ ^[Yy]$ ]]; then
    # Determine shell profile
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_PROFILE="$HOME/.zshrc"
    else
        SHELL_PROFILE="$HOME/.bash_profile"
    fi

    echo "📝 Adding to $SHELL_PROFILE..."

    # Add to .env file for local development
    cat >> .env << EOF

# Stripe Configuration
STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
EOF

    # Add to shell profile
    echo "" >> "$SHELL_PROFILE"
    echo "# Stripe Configuration" >> "$SHELL_PROFILE"
    echo "export STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" >> "$SHELL_PROFILE"
    echo "export STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" >> "$SHELL_PROFILE"

    echo "✅ Environment variables added to .env and $SHELL_PROFILE"
    echo "🔄 Please run: source $SHELL_PROFILE"
else
    echo "📝 Creating .env file only..."
    
    cat >> .env << EOF

# Stripe Configuration
STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
EOF

    echo "✅ Environment variables added to .env file"
fi

echo ""
echo "🔧 Next Steps:"
echo "=============="
echo "1. Update Rails credentials to use environment variables:"
echo "   EDITOR='code --wait' bin/rails credentials:edit"
echo "   Change the stripe section to:"
echo "   stripe:"
echo "     secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>"
echo "     publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>"
echo "     webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>"
echo ""
echo "2. Add Stripe variables to Kamal secrets (.kamal/secrets):"
echo "   STRIPE_SECRET_KEY=\$STRIPE_SECRET_KEY"
echo "   STRIPE_PUBLISHABLE_KEY=\$STRIPE_PUBLISHABLE_KEY"
echo "   STRIPE_WEBHOOK_SECRET=\$STRIPE_WEBHOOK_SECRET"
echo ""
echo "3. Add Stripe variables to deploy.yml (config/deploy.yml):"
echo "   Under env:secret: add:"
echo "   - STRIPE_SECRET_KEY"
echo "   - STRIPE_PUBLISHABLE_KEY"
echo "   - STRIPE_WEBHOOK_SECRET"
echo ""
echo "4. Set the webhook secret environment variable:"
echo "   export STRIPE_WEBHOOK_SECRET='whsec_your_webhook_secret_here'"
echo ""
echo "5. Deploy to production:"
echo "   kamal deploy"
