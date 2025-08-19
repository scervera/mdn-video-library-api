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

# Get Zone ID
read -p "Enter your Cloudflare Zone ID (for root domain e.g. cerveras.com): " CLOUDFLARE_ZONE_ID
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


echo "=== Setup Complete ==="
echo ""
echo "Your Cloudflare configuration has been saved to .env file."
echo ""

# Ask if user wants to set environment variables on dev machine
read -p "Would you like to set these environment variables on your dev machine? (y/n): " SET_ENV_VARS

if [[ "$SET_ENV_VARS" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Setting environment variables on your dev machine..."
    
    # Export DNS API Token
    export CLOUDFLARE_DNS_API_TOKEN="$CLOUDFLARE_DNS_API_TOKEN"
    echo "✅ CLOUDFLARE_DNS_API_TOKEN exported"
    
    # Export Zone ID
    export CLOUDFLARE_ZONE_ID="$CLOUDFLARE_ZONE_ID"
    echo "✅ CLOUDFLARE_ZONE_ID exported"
    
    # Export Stream API Token
    export CLOUDFLARE_STREAM_API_TOKEN="$CLOUDFLARE_STREAM_API_TOKEN"
    echo "✅ CLOUDFLARE_STREAM_API_TOKEN exported"
    
    # Export Stream Account ID
    export CLOUDFLARE_STREAM_ACCOUNT_ID="$CLOUDFLARE_STREAM_ACCOUNT_ID"
    echo "✅ CLOUDFLARE_STREAM_ACCOUNT_ID exported"
    
    echo ""
    echo "=== Validating Environment Variables ==="
    
    # Validate that all variables are set
    if [ -n "$CLOUDFLARE_DNS_API_TOKEN" ] && [ -n "$CLOUDFLARE_ZONE_ID" ] && [ -n "$CLOUDFLARE_STREAM_API_TOKEN" ] && [ -n "$CLOUDFLARE_STREAM_ACCOUNT_ID" ]; then
        echo "✅ All environment variables are set correctly"
        
        # Test the configuration
        echo ""
        echo "Testing configuration..."
        if command -v ruby >/dev/null 2>&1; then
            echo "Running configuration test..."
            ruby test_cloudflare_config.rb
        else
            echo "⚠️  Ruby not found, skipping configuration test"
        fi
        
    else
        echo "❌ Some environment variables are missing:"
        [ -z "$CLOUDFLARE_DNS_API_TOKEN" ] && echo "  - CLOUDFLARE_DNS_API_TOKEN"
        [ -z "$CLOUDFLARE_ZONE_ID" ] && echo "  - CLOUDFLARE_ZONE_ID"
        [ -z "$CLOUDFLARE_STREAM_API_TOKEN" ] && echo "  - CLOUDFLARE_STREAM_API_TOKEN"
        [ -z "$CLOUDFLARE_STREAM_ACCOUNT_ID" ] && echo "  - CLOUDFLARE_STREAM_ACCOUNT_ID"
    fi
    
    echo ""
    echo "💡 Making environment variables permanent..."
    
    # Determine shell profile file
    if [[ "$SHELL" == *"zsh"* ]] || [ -n "$ZSH_VERSION" ]; then
        PROFILE_FILE="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]] || [ -n "$BASH_VERSION" ]; then
        PROFILE_FILE="$HOME/.bash_profile"
        if [ ! -f "$PROFILE_FILE" ]; then
            PROFILE_FILE="$HOME/.bashrc"
        fi
    else
        PROFILE_FILE="$HOME/.profile"
    fi
    
    echo "Adding environment variables to $PROFILE_FILE"
    
    # Remove existing Cloudflare exports if they exist
    sed -i '' '/export CLOUDFLARE_DNS_API_TOKEN=/d' "$PROFILE_FILE"
    sed -i '' '/export CLOUDFLARE_ZONE_ID=/d' "$PROFILE_FILE"
    sed -i '' '/export CLOUDFLARE_STREAM_API_TOKEN=/d' "$PROFILE_FILE"
    sed -i '' '/export CLOUDFLARE_STREAM_ACCOUNT_ID=/d' "$PROFILE_FILE"
    
    # Add new exports
    echo "" >> "$PROFILE_FILE"
    echo "# Cloudflare API Configuration" >> "$PROFILE_FILE"
    echo "export CLOUDFLARE_DNS_API_TOKEN=\"$CLOUDFLARE_DNS_API_TOKEN\"" >> "$PROFILE_FILE"
    echo "export CLOUDFLARE_ZONE_ID=\"$CLOUDFLARE_ZONE_ID\"" >> "$PROFILE_FILE"
    echo "export CLOUDFLARE_STREAM_API_TOKEN=\"$CLOUDFLARE_STREAM_API_TOKEN\"" >> "$PROFILE_FILE"
    echo "export CLOUDFLARE_STREAM_ACCOUNT_ID=\"$CLOUDFLARE_STREAM_ACCOUNT_ID\"" >> "$PROFILE_FILE"
    
    echo "✅ Environment variables added to $PROFILE_FILE"
    echo ""
    
    # Ask if user wants to apply changes immediately
    read -p "Would you like to apply these changes immediately? (y/n): " APPLY_NOW
    
    if [[ "$APPLY_NOW" =~ ^[Yy]$ ]]; then
        echo "Applying changes..."
        source "$PROFILE_FILE"
        echo "✅ Environment variables are now active in this session!"
    else
        echo "🔄 To apply changes later, run:"
        echo "   source $PROFILE_FILE"
        echo ""
        echo "Or restart your terminal session."
    fi
    
else
    echo ""
    echo "Environment variables were not set on your dev machine."
    echo "You can set them manually when needed:"
    echo "  export CLOUDFLARE_DNS_API_TOKEN=\"$CLOUDFLARE_DNS_API_TOKEN\""
    echo "  export CLOUDFLARE_ZONE_ID=\"$CLOUDFLARE_ZONE_ID\""
    echo "  export CLOUDFLARE_STREAM_API_TOKEN=\"$CLOUDFLARE_STREAM_API_TOKEN\""
    echo "  export CLOUDFLARE_STREAM_ACCOUNT_ID=\"$CLOUDFLARE_STREAM_ACCOUNT_ID\""
fi

echo ""
echo "For production deployment with Kamal:"
echo "1. Ensure environment variables are set on your local machine"
echo "2. Deploy to production: kamal deploy"
echo ""
echo "Note: Kamal will automatically copy your local environment variables to production."
echo ""
echo "Current .env contents:"
echo "======================"
cat .env
echo "======================"
