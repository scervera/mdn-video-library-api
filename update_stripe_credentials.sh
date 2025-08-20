#!/bin/bash

echo "🔧 Updating Rails Credentials for Stripe Environment Variables"
echo "=============================================================="
echo ""

echo "📝 Current credentials structure:"
bin/rails credentials:show | grep -A 5 -B 5 stripe
echo ""

echo "🔄 Updating credentials to use environment variables..."
echo ""

# Create a temporary file with the updated credentials
cat > /tmp/stripe_credentials.yml << 'EOF'
# This file will be used to update the Rails credentials
# The stripe section should be updated to use environment variables

stripe:
  secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>
  publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>
  webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>
EOF

echo "📋 Instructions for updating credentials:"
echo "1. Run: EDITOR='code --wait' bin/rails credentials:edit"
echo "2. Find the 'stripe:' section"
echo "3. Replace the current values with:"
echo "   secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>"
echo "   publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>"
echo "   webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>"
echo "4. Save and close the editor"
echo ""

echo "🔑 Current environment variables:"
echo "STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY:0:20}..."
echo "STRIPE_PUBLISHABLE_KEY: ${STRIPE_PUBLISHABLE_KEY:0:20}..."
echo "STRIPE_WEBHOOK_SECRET: ${STRIPE_WEBHOOK_SECRET:-'Not set'}"
echo ""

echo "⚠️  Note: You'll need to set STRIPE_WEBHOOK_SECRET after creating the webhook in Stripe Workbench"
echo ""
