#!/bin/bash

echo "🔧 Complete Stripe Webhook Setup Guide"
echo "======================================"
echo ""

# Check if Stripe CLI is logged in
if ! stripe config --list > /dev/null 2>&1; then
    echo "❌ Stripe CLI not logged in. Please run: stripe login"
    exit 1
fi

echo "✅ Stripe CLI is logged in"
echo ""

# Get account info
ACCOUNT_ID=$(stripe config --list | grep "account_id" | cut -d"'" -f2)
echo "📊 Account ID: $ACCOUNT_ID"
echo ""

echo "🌐 Step 1: Open Stripe Workbench"
echo "================================="
echo "1. Go to: https://workbench.stripe.com/"
echo "2. Sign in with your Stripe account"
echo "3. You should see your account: Curriculum SaaS"
echo ""

echo "🔗 Step 2: Create Webhook Endpoint"
echo "=================================="
echo "1. In Workbench, click on 'Webhooks' in the left sidebar"
echo "2. Click 'Create endpoint'"
echo "3. Set the endpoint URL to: https://curriculum-library-api.cerveras.com/api/v1/webhooks/stripe"
echo "4. Select these events:"
echo "   - account.updated"
echo "   - customer.subscription.updated"
echo "   - customer.subscription.deleted"
echo "   - invoice.payment_failed"
echo "   - invoice.payment_succeeded"
echo "   - payment_intent.succeeded"
echo "   - payment_intent.payment_failed"
echo "   - setup_intent.succeeded"
echo "   - setup_intent.setup_failed"
echo "5. Click 'Create endpoint'"
echo ""

echo "🔑 Step 3: Get Webhook Secret"
echo "=============================="
echo "1. After creating the endpoint, click on it"
echo "2. Copy the 'Signing secret' (starts with 'whsec_')"
echo "3. We'll add this to Rails credentials"
echo ""

echo "📝 Step 4: Add to Rails Credentials"
echo "==================================="
echo "Run this command (replace WH_SECRET with your actual secret):"
echo ""
echo "EDITOR='code --wait' bin/rails credentials:edit"
echo ""
echo "Add this to the stripe section:"
echo "  webhook_secret: 'whsec_your_secret_here'"
echo ""

echo "🧪 Step 5: Test Webhook Locally"
echo "==============================="
echo "To test webhooks locally, run:"
echo "stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe"
echo ""

echo "🚀 Step 6: Deploy to Production"
echo "==============================="
echo "After adding the webhook secret to credentials:"
echo "kamal deploy"
echo ""

echo "✅ Setup Complete!"
echo "=================="
echo "Your Stripe webhook is now configured to handle payment events."
echo "The webhook will automatically update subscription status,"
echo "process payments, and handle account updates."
