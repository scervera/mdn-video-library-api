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

# Get Subdomain (for Cloudflare functionality)
read -p "Enter your subdomain for Cloudflare functionality (e.g. curriculum): " CLOUDFLARE_SUBDOMAIN
if [ -n "$CLOUDFLARE_SUBDOMAIN" ]; then
    # Remove existing CLOUDFLARE_SUBDOMAIN if it exists
    sed -i '' '/CLOUDFLARE_SUBDOMAIN=/d' .env
    echo "CLOUDFLARE_SUBDOMAIN=$CLOUDFLARE_SUBDOMAIN" >> .env
    echo "✅ Subdomain added to .env file"
else
    echo "❌ Subdomain is required"
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
    
    # Export Subdomain
    export CLOUDFLARE_SUBDOMAIN="$CLOUDFLARE_SUBDOMAIN"
    echo "✅ CLOUDFLARE_SUBDOMAIN exported"
    

    
    # Export Stream API Token
    export CLOUDFLARE_STREAM_API_TOKEN="$CLOUDFLARE_STREAM_API_TOKEN"
    echo "✅ CLOUDFLARE_STREAM_API_TOKEN exported"
    
    # Export Stream Account ID
    export CLOUDFLARE_STREAM_ACCOUNT_ID="$CLOUDFLARE_STREAM_ACCOUNT_ID"
    echo "✅ CLOUDFLARE_STREAM_ACCOUNT_ID exported"
    
    echo ""
    echo "=== Validating Environment Variables ==="
    
    # Validate that all variables are set
    if [ -n "$CLOUDFLARE_SUBDOMAIN" ] && [ -n "$CLOUDFLARE_STREAM_API_TOKEN" ] && [ -n "$CLOUDFLARE_STREAM_ACCOUNT_ID" ]; then
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
        [ -z "$CLOUDFLARE_SUBDOMAIN" ] && echo "  - CLOUDFLARE_SUBDOMAIN"
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
    sed -i '' '/export CLOUDFLARE_SUBDOMAIN=/d' "$PROFILE_FILE"
    sed -i '' '/export CLOUDFLARE_STREAM_API_TOKEN=/d' "$PROFILE_FILE"
    sed -i '' '/export CLOUDFLARE_STREAM_ACCOUNT_ID=/d' "$PROFILE_FILE"
    
    # Add new exports
    echo "" >> "$PROFILE_FILE"
    echo "# Cloudflare API Configuration" >> "$PROFILE_FILE"
    echo "export CLOUDFLARE_SUBDOMAIN=\"$CLOUDFLARE_SUBDOMAIN\"" >> "$PROFILE_FILE"
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
        echo "  export CLOUDFLARE_SUBDOMAIN=\"$CLOUDFLARE_SUBDOMAIN\""
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
