#!/bin/bash

echo "🔧 Adding secret_key_base to Rails credentials"
echo "=============================================="
echo ""

# Generate a new secret key base
SECRET_KEY_BASE=$(bin/rails secret)

echo "📝 Generated new secret_key_base: ${SECRET_KEY_BASE:0:20}..."
echo ""

echo "📋 Instructions to add secret_key_base to credentials:"
echo "1. Run: EDITOR='nano' bin/rails credentials:edit"
echo "2. Add this line at the top of the file:"
echo "   secret_key_base: $SECRET_KEY_BASE"
echo "3. Save and exit (Ctrl+X, Y, Enter in nano)"
echo ""

echo "🔑 Or you can copy this exact content to add to your credentials:"
echo "secret_key_base: $SECRET_KEY_BASE"
echo ""

echo "✅ After adding this, Rails will use the secret_key_base from credentials"
echo "   and Stripe configuration will use environment variables via Kamal secrets"
