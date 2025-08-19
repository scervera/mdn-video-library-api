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

# Get API Token
read -p "Enter your Cloudflare API Token: " CLOUDFLARE_API_TOKEN
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    # Remove existing CLOUDFLARE_API_TOKEN if it exists
    sed -i '' '/CLOUDFLARE_API_TOKEN=/d' .env
    echo "CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN" >> .env
    echo "✅ API Token added to .env file"
else
    echo "❌ API Token is required"
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
echo "1. Set the secrets: kamal secrets set CLOUDFLARE_API_TOKEN=your_token"
echo "2. Set the secrets: kamal secrets set CLOUDFLARE_ZONE_ID=your_zone_id"
echo ""
echo "Current .env contents:"
echo "======================"
cat .env
echo "======================"
