#!/bin/bash

echo "=== Cloudflare Environment Setup ==="
echo ""
echo "This script will help you set up Cloudflare environment variables for local development."
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    touch .env
fi

echo "Please provide your Cloudflare credentials:"
echo ""

# Get DNS API Token
read -p "Enter your Cloudflare DNS API Token (for managing subdomains): " CLOUDFLARE_DNS_API_TOKEN
if [ -n "$CLOUDFLARE_DNS_API_TOKEN" ]; then
    # Remove existing CLOUDFLARE_DNS_API_TOKEN if it exists
    sed -i '' '/CLOUDFLARE_DNS_API_TOKEN=/d' .env
    echo "CLOUDFLARE_DNS_API_TOKEN=$CLOUDFLARE_DNS_API_TOKEN" >> .env
    echo "✅ DNS API Token added to .env file"
else
    echo "❌ DNS API Token is required"
    exit 1
fi

echo ""

# Get Stream API Token
read -p "Enter your Cloudflare Stream API Token (for video hosting): " CLOUDFLARE_STREAM_API_TOKEN
if [ -n "$CLOUDFLARE_STREAM_API_TOKEN" ]; then
    # Remove existing CLOUDFLARE_STREAM_API_TOKEN if it exists
    sed -i '' '/CLOUDFLARE_STREAM_API_TOKEN=/d' .env
    echo "CLOUDFLARE_STREAM_API_TOKEN=$CLOUDFLARE_STREAM_API_TOKEN" >> .env
    echo "✅ Stream API Token added to .env file"
else
    echo "❌ Stream API Token is required"
    exit 1
fi

echo ""

# Get Stream Account ID
read -p "Enter your Cloudflare Stream Account ID: " CLOUDFLARE_STREAM_ACCOUNT_ID
if [ -n "$CLOUDFLARE_STREAM_ACCOUNT_ID" ]; then
    # Remove existing CLOUDFLARE_STREAM_ACCOUNT_ID if it exists
    sed -i '' '/CLOUDFLARE_STREAM_ACCOUNT_ID=/d' .env
    echo "CLOUDFLARE_STREAM_ACCOUNT_ID=$CLOUDFLARE_STREAM_ACCOUNT_ID" >> .env
    echo "✅ Stream Account ID added to .env file"
else
    echo "❌ Stream Account ID is required"
    exit 1
fi

echo ""

# Get Zone ID
read -p "Enter your Cloudflare Zone ID (for cerveras.com): " CLOUDFLARE_ZONE_ID
if [ -n "$CLOUDFLARE_ZONE_ID" ]; then
    # Remove existing CLOUDFLARE_ZONE_ID if it exists
    sed -i '' '/CLOUDFLARE_ZONE_ID=/d' .env
    echo "CLOUDFLARE_ZONE_ID=$CLOUDFLARE_ZONE_ID" >> .env
    echo "✅ Zone ID added to .env file"
else
    echo "❌ Zone ID is required"
    exit 1
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Your Cloudflare credentials have been added to .env file."
echo ""
echo "To use these in development, you can:"
echo "1. Source the .env file: source .env"
echo "2. Or use dotenv gem (recommended)"
echo ""
echo "For production deployment with Kamal:"
echo "1. Set environment variables on your local machine:"
echo "   export CLOUDFLARE_DNS_API_TOKEN=your_dns_token"
echo "   export CLOUDFLARE_ZONE_ID=your_zone_id"
echo "   export CLOUDFLARE_STREAM_API_TOKEN=your_stream_token"
echo "   export CLOUDFLARE_STREAM_ACCOUNT_ID=your_stream_account_id"
echo ""
echo "2. Deploy to production:"
echo "   kamal deploy"
echo ""
echo "Note: Kamal will automatically copy your local environment variables to production."
echo ""
echo "Current .env contents:"
echo "======================"
cat .env
echo "======================"
