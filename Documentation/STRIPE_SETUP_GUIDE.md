# Stripe Integration Setup Guide

This guide provides step-by-step instructions for setting up Stripe integration on a new system.

## Prerequisites

Before setting up Stripe integration, ensure you have:

1. **Stripe CLI installed**
   ```bash
   # macOS
   brew install stripe/stripe-cli/stripe
   
   # Linux
   # Follow instructions at: https://stripe.com/docs/stripe-cli#install
   ```

2. **Stripe CLI logged in**
   ```bash
   stripe login
   ```

3. **Rails application set up**
   ```bash
   bin/setup
   ```

## Quick Setup (Recommended)

For a new system, run the automated setup script:

```bash
bin/setup_stripe.sh
```

This script will:
- ✅ Check Stripe CLI installation and login
- ✅ Retrieve Stripe API keys from CLI
- ✅ Set up environment variables
- ✅ Update Rails credentials
- ✅ Configure Kamal secrets
- ✅ Set up webhook secrets
- ✅ Run database setup tasks

## Manual Setup

If you prefer to set up manually or need to troubleshoot, follow these steps:

### Step 1: Get Stripe API Keys

1. **Install and login to Stripe CLI**
   ```bash
   stripe login
   ```

2. **Retrieve your API keys**
   ```bash
   stripe config --list
   ```

3. **Note the keys**:
   - `test_mode_api_key` (starts with `sk_test_`)
   - `test_mode_pub_key` (starts with `pk_test_`)

### Step 2: Set Environment Variables

1. **Add to your shell profile** (`.zshrc` or `.bash_profile`)
   ```bash
   export STRIPE_SECRET_KEY="sk_test_your_secret_key_here"
   export STRIPE_PUBLISHABLE_KEY="pk_test_your_publishable_key_here"
   export STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret_here"
   ```

2. **Create `.env` file** (for local development)
   ```bash
   # Stripe Configuration
   STRIPE_SECRET_KEY=sk_test_your_secret_key_here
   STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
   STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
   ```

3. **Reload your shell profile**
   ```bash
   source ~/.zshrc  # or ~/.bash_profile
   ```

### Step 3: Update Rails Credentials

1. **Edit Rails credentials**
   ```bash
   EDITOR="cursor" bin/rails credentials:edit
   ```

2. **Add Stripe configuration**
   ```yaml
   stripe:
     secret_key: <%= ENV['STRIPE_SECRET_KEY'] %>
     publishable_key: <%= ENV['STRIPE_PUBLISHABLE_KEY'] %>
     webhook_secret: <%= ENV['STRIPE_WEBHOOK_SECRET'] %>
   ```

### Step 4: Configure Kamal Secrets

1. **Edit `.kamal/secrets`**
   ```bash
   # Add these lines to .kamal/secrets
   STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY
   STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
   STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET
   ```

### Step 5: Set Up Webhook Secret

1. **Go to Stripe Dashboard**
   - Visit: https://dashboard.stripe.com/webhooks

2. **Create webhook endpoint**
   - URL: `https://curriculum-library-api.cerveras.com/api/v1/webhooks/stripe`
   - Events to select:
     - `account.updated`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `invoice.payment_failed`
     - `invoice.payment_succeeded`
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
     - `setup_intent.succeeded`
     - `setup_intent.setup_failed`

3. **Copy webhook signing secret**
   - Starts with `whsec_`
   - Add to your environment variables

### Step 6: Run Database Setup

1. **Set up Stripe customers and prices**
   ```bash
   bin/rails stripe:setup
   ```

2. **Verify setup**
   ```bash
   bin/rails stripe:setup_customers
   bin/rails stripe:setup_prices
   ```

### Step 7: Deploy to Production

1. **Deploy the application**
   ```bash
   kamal deploy
   ```

2. **Set up production environment variables**
   ```bash
   # Set these on your production server
   export STRIPE_SECRET_KEY="sk_test_your_secret_key_here"
   export STRIPE_PUBLISHABLE_KEY="pk_test_your_publishable_key_here"
   export STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret_here"
   ```

3. **Run Stripe setup on production**
   ```bash
   kamal app exec bin/rails stripe:setup
   ```

## Verification

### Local Testing

1. **Test Stripe API connection**
   ```bash
   bin/rails stripe:setup
   ```

2. **Check environment variables**
   ```bash
   echo $STRIPE_SECRET_KEY
   echo $STRIPE_PUBLISHABLE_KEY
   ```

3. **Test webhook endpoint** (if configured)
   ```bash
   stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
   ```

### Production Testing

1. **Check production environment**
   ```bash
   kamal app exec env | grep STRIPE
   ```

2. **Test production setup**
   ```bash
   kamal app exec bin/rails stripe:setup
   ```

## Troubleshooting

### Common Issues

1. **"API key is invalid, as it contains whitespace"**
   - Solution: Ensure no newline characters in environment variables
   - Check: `echo "$STRIPE_SECRET_KEY" | wc -c` (should be 107)

2. **"Stripe CLI not logged in"**
   - Solution: Run `stripe login`

3. **"Could not retrieve Stripe keys"**
   - Solution: Check Stripe CLI configuration with `stripe config --list`

4. **"Webhook signature verification failed"**
   - Solution: Ensure webhook secret is correct and matches Stripe Dashboard

5. **"Rails credentials don't support ERB"**
   - Solution: Use environment variables directly in `StripeService`

### Environment Variable Issues

If environment variables aren't being read correctly:

1. **Check shell profile**
   ```bash
   cat ~/.zshrc | grep STRIPE
   ```

2. **Reload shell profile**
   ```bash
   source ~/.zshrc
   ```

3. **Verify in Rails console**
   ```bash
   bin/rails console
   > ENV['STRIPE_SECRET_KEY']
   ```

## Security Notes

- ✅ **Never commit API keys to git**
- ✅ **Use environment variables for all secrets**
- ✅ **Use test keys for development**
- ✅ **Use live keys only in production**
- ✅ **Rotate keys regularly**
- ✅ **Monitor Stripe Dashboard for suspicious activity**

## Next Steps

After setup is complete:

1. **Test subscription creation**
2. **Test payment processing**
3. **Test webhook handling**
4. **Monitor Stripe Dashboard**
5. **Set up monitoring and alerts**

## Support

- **Stripe Documentation**: https://stripe.com/docs
- **Stripe CLI**: https://stripe.com/docs/stripe-cli
- **Stripe Webhooks**: https://stripe.com/docs/webhooks
- **Stripe Test Cards**: https://stripe.com/docs/testing
