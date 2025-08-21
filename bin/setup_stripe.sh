#!/bin/bash

echo "🚀 Stripe Integration Setup for New Systems"
echo "==========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -f "config/application.rb" ]; then
    print_error "This script must be run from the Rails application root directory"
    exit 1
fi

print_status "Starting Stripe integration setup..."

# Step 1: Check if Stripe CLI is installed and logged in
print_status "Step 1: Checking Stripe CLI..."
if ! command -v stripe &> /dev/null; then
    print_error "Stripe CLI is not installed. Please install it first:"
    echo "  macOS: brew install stripe/stripe-cli/stripe"
    echo "  Linux: https://stripe.com/docs/stripe-cli#install"
    exit 1
fi

if ! stripe config --list > /dev/null 2>&1; then
    print_warning "Stripe CLI not logged in. Please run: stripe login"
    echo ""
    echo "After logging in, run this script again."
    exit 1
fi

print_success "Stripe CLI is installed and logged in"

# Step 2: Get Stripe keys from CLI
print_status "Step 2: Getting Stripe keys from CLI..."
STRIPE_SECRET_KEY=$(stripe config --list | grep "test_mode_api_key" | cut -d"'" -f2)
STRIPE_PUBLISHABLE_KEY=$(stripe config --list | grep "test_mode_pub_key" | cut -d"'" -f2)

if [ -z "$STRIPE_SECRET_KEY" ] || [ -z "$STRIPE_PUBLISHABLE_KEY" ]; then
    print_error "Could not retrieve Stripe keys from CLI. Please ensure you're logged in: stripe login"
    exit 1
fi

print_success "Retrieved Stripe keys from CLI"
echo "  Secret Key: ${STRIPE_SECRET_KEY:0:20}..."
echo "  Publishable Key: ${STRIPE_PUBLISHABLE_KEY:0:20}..."

# Step 3: Set up environment variables
print_status "Step 3: Setting up environment variables..."

# Determine shell profile
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
else
    SHELL_PROFILE="$HOME/.bash_profile"
fi

# Create .env file
cat > .env << EOF
# Stripe Configuration
STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
EOF

print_success "Created .env file"

# Add to shell profile
if ! grep -q "STRIPE_SECRET_KEY" "$SHELL_PROFILE"; then
    echo "" >> "$SHELL_PROFILE"
    echo "# Stripe Configuration" >> "$SHELL_PROFILE"
    echo "export STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" >> "$SHELL_PROFILE"
    echo "export STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" >> "$SHELL_PROFILE"
    print_success "Added Stripe keys to $SHELL_PROFILE"
else
    print_warning "Stripe keys already exist in $SHELL_PROFILE"
fi

# Step 4: Update Rails credentials
print_status "Step 4: Updating Rails credentials..."

# Create temporary credentials file
cat > /tmp/stripe_credentials.yml << EOF
stripe:
  secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>
  publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>
  webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>
EOF

# Update credentials
if EDITOR="cp /tmp/stripe_credentials.yml" bin/rails credentials:edit; then
    print_success "Updated Rails credentials"
else
    print_error "Failed to update Rails credentials"
    rm -f /tmp/stripe_credentials.yml
    exit 1
fi

rm -f /tmp/stripe_credentials.yml

# Step 5: Update Kamal secrets
print_status "Step 5: Updating Kamal secrets..."

# Check if .kamal/secrets exists
if [ ! -f ".kamal/secrets" ]; then
    print_error ".kamal/secrets file not found. Please run 'kamal setup' first."
    exit 1
fi

# Add Stripe variables to Kamal secrets if they don't exist
if ! grep -q "STRIPE_SECRET_KEY" ".kamal/secrets"; then
    echo "" >> .kamal/secrets
    echo "# Stripe Configuration" >> .kamal/secrets
    echo "STRIPE_SECRET_KEY=\$STRIPE_SECRET_KEY" >> .kamal/secrets
    echo "STRIPE_PUBLISHABLE_KEY=\$STRIPE_PUBLISHABLE_KEY" >> .kamal/secrets
    echo "STRIPE_WEBHOOK_SECRET=\$STRIPE_WEBHOOK_SECRET" >> .kamal/secrets
    print_success "Added Stripe variables to .kamal/secrets"
else
    print_warning "Stripe variables already exist in .kamal/secrets"
fi

# Step 6: Update deploy.yml
print_status "Step 6: Checking deploy.yml configuration..."

if [ -f "config/deploy.yml" ]; then
    if ! grep -q "STRIPE_SECRET_KEY" "config/deploy.yml"; then
        print_warning "Please add Stripe variables to config/deploy.yml under env:secret:"
        echo "  - STRIPE_SECRET_KEY"
        echo "  - STRIPE_PUBLISHABLE_KEY"
        echo "  - STRIPE_WEBHOOK_SECRET"
    else
        print_success "Stripe variables already configured in deploy.yml"
    fi
else
    print_warning "config/deploy.yml not found. Please ensure it's configured for Stripe variables."
fi

# Step 7: Set up webhook secret
print_status "Step 7: Setting up webhook secret..."

echo ""
echo "🔧 Webhook Setup Instructions:"
echo "=============================="
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

echo "Enter your Stripe webhook signing secret (or press Enter to skip):"
read -s WEBHOOK_SECRET

if [ -n "$WEBHOOK_SECRET" ]; then
    # Update .env file
    sed -i.bak "s/STRIPE_WEBHOOK_SECRET=.*/STRIPE_WEBHOOK_SECRET=$WEBHOOK_SECRET/" .env
    rm -f .env.bak
    
    # Update shell profile
    if ! grep -q "STRIPE_WEBHOOK_SECRET" "$SHELL_PROFILE"; then
        echo "export STRIPE_WEBHOOK_SECRET=$WEBHOOK_SECRET" >> "$SHELL_PROFILE"
    fi
    
    print_success "Webhook secret configured"
else
    print_warning "Webhook secret not provided. You'll need to set it later."
fi

# Step 8: Run Stripe setup rake task
print_status "Step 8: Running Stripe setup rake task..."

# Source the shell profile to get the environment variables
source "$SHELL_PROFILE"

if bin/rails stripe:setup; then
    print_success "Stripe setup rake task completed"
else
    print_error "Stripe setup rake task failed"
    exit 1
fi

# Step 9: Final instructions
echo ""
print_success "Stripe integration setup completed!"
echo ""
echo "🔧 Next Steps:"
echo "=============="
echo "1. Source your shell profile: source $SHELL_PROFILE"
echo "2. Test the setup locally: bin/rails stripe:setup"
echo "3. Deploy to production: kamal deploy"
echo "4. Set up webhook secret in production environment"
echo "5. Run Stripe setup on production: kamal app exec bin/rails stripe:setup"
echo ""
echo "📚 Documentation:"
echo "================="
echo "- Stripe Dashboard: https://dashboard.stripe.com"
echo "- Stripe CLI: https://stripe.com/docs/stripe-cli"
echo "- Stripe Webhooks: https://stripe.com/docs/webhooks"
echo ""
print_success "Setup complete! 🎉"
