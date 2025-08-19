# Stripe Billing System Implementation Plan

## Overview
This document outlines the complete implementation plan for the Stripe billing system with tenant-owned Stripe accounts, user invitations, and multi-tier subscription management.

## Architecture Decisions
- **Tenant-owned Stripe accounts**: Each tenant manages their own Stripe account via Stripe Connect
- **Fixed per-user pricing**: Professional tier charges fixed rate per user (not percentage)
- **Path-based multitenancy**: Frontend URLs use `curriculum.cerveras.com/{slug}` format
- **API header identification**: Backend APIs use `X-Tenant` header for tenant context
- **Configuration-driven pricing**: JSON config file for easy tier updates
- **Environment variable management**: Kamal secrets + `.env` for local development

## Implementation Phases

### ✅ **Phase 1: Billing Management APIs (COMPLETED)**
**Status**: Fully implemented and tested

**Completed Components**:
- ✅ Database schema (5 new tables with proper indexes)
- ✅ Models with validations and associations
- ✅ BillingConfiguration service for JSON config management
- ✅ API controllers for billing management
- ✅ Seeds with billing data for all tenants

**API Endpoints Implemented**:
```
GET /api/v1/billing_tiers           # List all tiers (no auth)
GET /api/v1/billing_tiers/:id       # Get tier details (no auth)
GET /api/v1/subscriptions           # List tenant subscriptions (admin)
POST /api/v1/subscriptions          # Create subscription (admin)
PUT /api/v1/subscriptions/:id       # Update subscription (admin)
DELETE /api/v1/subscriptions/:id/cancel # Cancel subscription (admin)
GET /api/v1/trial/status             # Trial status (admin)
POST /api/v1/trial/start             # Start trial (admin)
POST /api/v1/trial/convert           # Convert trial (admin)
GET /api/v1/trial/expired            # List expired trials (admin)
```

**Billing Tiers**:
- **Trial**: 30 days, 10 users, $0
- **Starter**: 25 users, $99/month
- **Professional**: Unlimited users, $49/month + $15/user
- **Enterprise**: Unlimited users, $299/month

### 🔄 **Phase 2: User Invitation System (NEXT)**
**Status**: Ready to implement

**Components to Build**:
- [ ] Invitation controllers (create, list, accept, resend)
- [ ] Email integration with Brevo SMTP
- [ ] Token validation and security
- [ ] User registration via invitation
- [ ] Invitation management UI

**API Endpoints to Implement**:
```
POST /api/v1/invitations            # Create invitation (admin)
GET /api/v1/invitations             # List invitations (admin)
POST /api/v1/invitations/:token/accept # Accept invitation (no auth)
DELETE /api/v1/invitations/:id      # Cancel invitation (admin)
POST /api/v1/invitations/:id/resend # Resend invitation (admin)
```

**Environment Variables Needed**:
```
BREVO_SMTP_API_KEY=your_brevo_api_key
FRONTEND_URL=https://curriculum.cerveras.com
```

### 🔄 **Phase 3: Stripe Connect Integration**
**Status**: Ready to implement

**Components to Build**:
- [ ] Stripe Connect OAuth flow endpoints
- [ ] Connect account management
- [ ] Account status updates
- [ ] Frontend redirect handling

**API Endpoints to Implement**:
```
POST /api/v1/stripe/connect/create   # Create Connect account (admin)
GET /api/v1/stripe/connect/status    # Connect account status (admin)
POST /api/v1/stripe/connect/refresh  # Refresh account status (admin)
```

### 🔄 **Phase 4: User Subscription Management (Professional Tier)**
**Status**: Ready to implement

**Components to Build**:
- [ ] Individual user subscription creation
- [ ] Subscription management for per-user billing
- [ ] Usage tracking and billing
- [ ] User subscription cancellation

**API Endpoints to Implement**:
```
POST /api/v1/user_subscriptions      # Create user subscription
GET /api/v1/user_subscriptions       # List user subscriptions
DELETE /api/v1/user_subscriptions/:id # Cancel user subscription
```

### 🔄 **Phase 5: Webhook System**
**Status**: Ready to implement

**Components to Build**:
- [ ] Stripe webhook endpoint
- [ ] Event processing (payment success/failure, subscription updates)
- [ ] Webhook signature verification
- [ ] Event logging and error handling

**API Endpoints to Implement**:
```
POST /api/v1/webhooks/stripe         # Stripe webhook handler (no auth)
```

### 🔄 **Phase 6: Environment Configuration & Production**
**Status**: Ready to implement

**Components to Configure**:
- [ ] Stripe API keys (test and live)
- [ ] Webhook secrets
- [ ] Brevo SMTP configuration
- [ ] Frontend URL configuration
- [ ] Production deployment with Kamal

**Environment Variables**:
```
STRIPE_PUBLIC_KEY=pk_live_xxx
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
BREVO_SMTP_API_KEY=your_api_key
FRONTEND_URL=https://curriculum.cerveras.com
```

## Database Schema Summary

### New Tables Added:
1. **billing_tiers**: Pricing tier definitions per tenant
2. **tenant_subscriptions**: Tenant-level subscription management
3. **user_subscriptions**: Individual user subscriptions (Professional tier)
4. **user_invitations**: Secure invitation system with tokens
5. **stripe_connect_accounts**: Tenant Stripe Connect account management

### Key Relationships:
- Tenant → BillingTiers (one-to-many)
- Tenant → TenantSubscription (one-to-many, but typically one active)
- TenantSubscription → UserSubscriptions (one-to-many)
- Tenant → UserInvitations (one-to-many)
- Tenant → StripeConnectAccount (one-to-one)

## Security Features
- ✅ **Tenant isolation**: All data scoped via `X-Tenant` header
- ✅ **Admin-only management**: Subscription endpoints require admin role
- ✅ **Secure tokens**: Cryptographically secure invitation tokens
- ✅ **Single-use invitations**: 14-day expiry, one-time use
- [ ] **Webhook verification**: Stripe signature validation
- [ ] **Rate limiting**: Prevent abuse of invitation system

## Configuration Management
- ✅ **Billing tiers**: `config/billing_tiers.json`
- ✅ **Environment variables**: `.env` for local, Kamal secrets for production
- ✅ **Rails credentials**: Explicitly not used per user preference
- [ ] **Email templates**: To be configured for Brevo

## Testing Strategy
- ✅ **Database seeding**: All tenants have billing data
- ✅ **API endpoints**: Billing tiers tested and working
- [ ] **Invitation flow**: End-to-end testing needed
- [ ] **Stripe integration**: Test with Stripe test mode
- [ ] **Email delivery**: Test with Brevo sandbox

## Next Session Resumption
To resume work on this billing system:

1. **Current branch**: `feature/stripe-billing-system`
2. **Last completed**: Phase 1 - Billing Management APIs
3. **Next priority**: Phase 2 - User Invitation System
4. **Key files**: 
   - Models in `app/models/` (billing_tier.rb, tenant_subscription.rb, etc.)
   - Controllers in `app/controllers/api/v1/` (billing_tiers_controller.rb, etc.)
   - Configuration in `config/billing_tiers.json`
   - Services in `app/services/` (billing_configuration.rb, stripe_service.rb)

## Environment Setup Commands
```bash
# Switch to billing branch
git checkout feature/stripe-billing-system

# Install dependencies
bundle install

# Run migrations and seed
bin/rails db:migrate
bin/rails db:seed

# Test billing endpoints
curl -H "X-Tenant: acme1" http://localhost:3000/api/v1/billing_tiers
```
