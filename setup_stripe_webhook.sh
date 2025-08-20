#!/bin/bash

echo "🔧 Setting up Stripe Webhook Secret"
echo "=================================="

echo "📝 Instructions:"
echo "1. Go to your Stripe Dashboard: https://dashboard.stripe.com/webhooks"
echo "2. Create a new webhook endpoint with URL: https://curriculum-library-api.cerveras.com/api/v1/webhooks/stripe"
echo "3. Select these events:"
echo "   - account.updated"
echo "   - customer.subscription.updated"
echo "   - customer.subscription.deleted"
echo "   - invoice.payment_failed"
echo "   - invoice.payment_succeeded"
echo "   - payment_intent.succeeded"
echo "   - payment_intent.payment_failed"
echo "   - setup_intent.succeeded"
echo "   - setup_intent.setup_failed"
echo "4. Copy the webhook signing secret (starts with 'whsec_')"
echo ""

echo "Enter your Stripe webhook signing secret:"
read -s WEBHOOK_SECRET

if [ -z "$WEBHOOK_SECRET" ]; then
    echo "❌ No webhook secret provided"
    exit 1
fi

echo ""
echo "🔑 Adding webhook secret to Rails credentials..."

# Create a temporary file with the new credentials
cat > /tmp/stripe_credentials.yml << EOF
stripe:
  secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>
  publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>
  webhook_secret: $WEBHOOK_SECRET
EOF

# Add to credentials
EDITOR="cp /tmp/stripe_credentials.yml" bin/rails credentials:edit

# Clean up
rm /tmp/stripe_credentials.yml

echo "✅ Webhook secret added to credentials!"
echo ""
echo "🔧 Next steps:"
echo "1. Test the webhook endpoint using Stripe CLI:"
echo "   stripe listen --forward-to https://curriculum-library-api.cerveras.com/api/v1/webhooks/stripe"
echo "2. Deploy the application to production"
echo "3. Verify webhook delivery in Stripe Dashboard"
