#!/bin/bash

echo "🔧 Fixing Stripe Credentials to Use Environment Variables"
echo "========================================================"
echo ""

echo "📝 Current credentials:"
bin/rails credentials:show | grep -A 3 stripe
echo ""

echo "🔄 The webhook_secret is still hardcoded. We need to update it to use environment variables."
echo ""

echo "📋 To fix this, you need to:"
echo "1. Run: EDITOR='code --wait' bin/rails credentials:edit"
echo "2. Find the stripe section"
echo "3. Change the webhook_secret line from:"
echo "   webhook_secret: whsec_IZrXkwylAbQ9ixKHkBWphW9FBVqC0z60"
echo "   to:"
echo "   webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>"
echo "4. Save and close the editor"
echo ""

echo "🔑 Then set the webhook secret environment variable:"
echo "export STRIPE_WEBHOOK_SECRET='whsec_IZrXkwylAbQ9ixKHkBWphW9FBVqC0z60'"
echo ""

echo "✅ After that, all Stripe configuration will use environment variables!"
