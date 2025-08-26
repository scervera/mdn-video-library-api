# Frontend Agent Prompt: Billing System UI Implementation

## Project Context
You are working on a **multitenant curriculum learning platform** built with Next.js. The backend Rails API has just implemented a comprehensive billing system with subscription management and trial periods. Your task is to create the frontend UI components and pages to interact with this billing system.

## Current Backend Status ✅
The Rails API has **Phase 1: Billing Management APIs** fully implemented and working. Here's what's available:

### Available API Endpoints
All endpoints require the `X-Tenant` header for tenant identification.

**Billing Tiers (No Authentication Required):**
```
GET /api/v1/billing_tiers
GET /api/v1/billing_tiers/:id
```

**Subscriptions (Admin Authentication Required):**
```
GET /api/v1/subscriptions           # List tenant subscriptions
POST /api/v1/subscriptions          # Create new subscription
PUT /api/v1/subscriptions/:id       # Update subscription
DELETE /api/v1/subscriptions/:id/cancel # Cancel subscription
```

**Trial Management (Admin Authentication Required):**
```
GET /api/v1/trial/status             # Get trial status and expiration
POST /api/v1/trial/start             # Start trial period
POST /api/v1/trial/convert           # Convert trial to active
GET /api/v1/trial/expired            # List expired trials
```

## Billing Tiers Available
The system supports these subscription tiers:

1. **Trial**: 30 days, 10 users, $0
2. **Starter**: 25 users, $99/month
3. **Professional**: Unlimited users, $49/month + $15/user
4. **Enterprise**: Unlimited users, $299/month

## Sample API Response Examples

### GET /api/v1/billing_tiers
```json
{
  "tiers": [
    {
      "id": "trial",
      "name": "Trial",
      "monthly_price": 0,
      "per_user_price": 0,
      "user_limit": 10,
      "features": ["basic_access", "up_to_10_users"],
      "description": "30-day free trial with up to 10 users"
    },
    {
      "id": "starter",
      "name": "Starter",
      "monthly_price": 99,
      "per_user_price": 0,
      "user_limit": 25,
      "features": ["full_access", "up_to_25_users"],
      "description": "Perfect for small teams up to 25 users"
    },
    {
      "id": "professional",
      "name": "Professional",
      "monthly_price": 49,
      "per_user_price": 15,
      "user_limit": null,
      "features": ["full_access", "unlimited_users", "per_user_billing"],
      "description": "Unlimited users with per-user billing"
    },
    {
      "id": "enterprise",
      "name": "Enterprise",
      "monthly_price": 299,
      "per_user_price": 0,
      "user_limit": null,
      "features": ["full_access", "unlimited_users", "priority_support"],
      "description": "Enterprise solution with unlimited users and priority support"
    }
  ],
  "invitation_expiry_days": 14,
  "trial_duration_days": 30,
  "supported_payment_methods": ["card"],
  "currencies": ["usd"]
}
```

### GET /api/v1/trial/status
```json
{
  "has_subscription": true,
  "trial_active": true,
  "trial_expired": false,
  "status": "trial",
  "trial_ends_at": "2025-09-18T23:59:59Z",
  "days_until_trial_expires": 23,
  "current_user_count": 2,
  "user_limit": 10,
  "can_add_user": true,
  "billing_tier": {
    "name": "Trial",
    "monthly_price": 0,
    "per_user_price": 0
  }
}
```

## Frontend Architecture Context

### URL Structure (Path-based Multitenancy)
- **Frontend URLs**: `curriculum.cerveras.com/{tenant-slug}`
- **Examples**: 
  - `curriculum.cerveras.com/acme1`
  - `curriculum.cerveras.com/acme2`
  - `curriculum.cerveras.com/acme3`

### API Configuration
- **API Base URL**: `https://curriculum-library-api.cerveras.com/api/v1`
- **Required Header**: `X-Tenant: {tenant-slug}`
- **Authentication**: Bearer token (when required)

### Existing Tenant Data
Three demo tenants are available for testing:
1. **ACME Corporation** (`acme1`) - Business focused
2. **TechStart Inc** (`acme2`) - Tech focused  
3. **Global Solutions** (`acme3`) - International focused

Each tenant has:
- Admin user: `admin_{slug}@{slug}.com` / `password`
- Demo user: `demo_{slug}@{slug}.com` / `password`
- Active trial subscription (30 days remaining)
- Unique curricula and branding

## Tasks to Implement

### 1. **Billing & Subscription Management Pages** (Admin Only)

#### a) **Subscription Dashboard** (`/admin/subscription`)
Create a comprehensive subscription management page for tenant admins:

**Components Needed:**
- Current subscription status card
- Trial expiration countdown (if applicable)
- User count vs. limits display
- Billing tier details
- Action buttons (upgrade, cancel, etc.)

**Data to Display:**
- Current plan name and features
- Monthly cost breakdown
- User limits and current usage
- Next billing date
- Trial status and days remaining

#### b) **Billing Tiers Page** (`/admin/billing`)
Create a pricing comparison page:

**Components Needed:**
- Tier comparison cards/table
- Feature comparison matrix
- Current tier highlighting
- Upgrade/downgrade buttons
- Per-user pricing calculator (for Professional tier)

**Features:**
- Calculate total cost for Professional tier based on user count
- Highlight recommended tier
- Clear call-to-action buttons
- Feature tooltips and explanations

#### c) **Trial Management** 
Integrate trial management into existing admin dashboard:

**Components Needed:**
- Trial status banner/alert
- Days remaining countdown
- Trial conversion flow
- User limit warnings

### 2. **User Experience Enhancements**

#### a) **Trial Expiration Warnings**
Create user-facing notifications for trial status:

**Components:**
- Top banner for trial users showing days remaining
- Modal/popup warnings at 7, 3, 1 day marks
- Gentle upgrade prompts in sidebar/navigation

#### b) **User Limit Enforcement**
Handle user limit scenarios gracefully:

**Features:**
- Disable "invite user" button when at limit
- Show upgrade prompt when trying to exceed limit
- Clear messaging about current usage

### 3. **Admin Navigation Updates**

Add billing-related navigation items to admin areas:
- Subscription dashboard link
- Billing settings link
- User management with limits display

### 4. **API Integration Layer**

#### a) **API Client Updates**
Extend your existing API client to handle billing endpoints:

```typescript
// Add these methods to your API client
getBillingTiers()
getSubscriptions()
getTrialStatus()
createSubscription(tierID: string)
updateSubscription(id: string, tierID: string)
cancelSubscription(id: string)
startTrial()
convertTrial()
```

#### b) **Type Definitions**
Create TypeScript types for all billing-related data:

```typescript
interface BillingTier {
  id: string;
  name: string;
  monthly_price: number;
  per_user_price: number;
  user_limit: number | null;
  features: string[];
  description: string;
}

interface TrialStatus {
  has_subscription: boolean;
  trial_active: boolean;
  trial_expired: boolean;
  status: string;
  trial_ends_at: string;
  days_until_trial_expires: number;
  current_user_count: number;
  user_limit: number;
  can_add_user: boolean;
  billing_tier: {
    name: string;
    monthly_price: number;
    per_user_price: number;
  };
}

interface Subscription {
  id: number;
  status: string;
  billing_tier: BillingTier;
  trial_ends_at: string | null;
  current_period_start: string | null;
  current_period_end: string | null;
  current_user_count: number;
  can_add_user: boolean;
  days_until_trial_expires: number | null;
}
```

## Design Guidelines

### Visual Design
- Use existing design system and component library
- Maintain consistent styling with current dashboard
- Implement proper loading states and error handling
- Use appropriate icons for billing/subscription concepts

### User Experience
- **Clear pricing display**: Show costs prominently and clearly
- **Progressive disclosure**: Don't overwhelm with all features at once
- **Contextual help**: Tooltips and explanations for billing terms
- **Responsive design**: Works on mobile and desktop
- **Accessibility**: Proper ARIA labels and keyboard navigation

### Error Handling
- Network errors for API calls
- Permission errors (non-admin users)
- Validation errors for subscription changes
- Trial expiration edge cases

## Testing Scenarios

### Test with Different Tenant States
1. **Active trial**: acme1, acme2, acme3 (fresh 30-day trials)
2. **Different user counts**: Add/remove users to test limits
3. **Admin vs regular users**: Ensure proper permission handling

### API Testing
Test all endpoints with different tenants:
```bash
# Test billing tiers (works for all tenants)
curl -H "X-Tenant: acme1" https://curriculum-library-api.cerveras.com/api/v1/billing_tiers

# Test trial status (requires admin auth)
curl -H "X-Tenant: acme1" -H "Authorization: Bearer {token}" \
  https://curriculum-library-api.cerveras.com/api/v1/trial/status
```

## Implementation Priority

### Phase 1: Core Subscription Dashboard
1. Create basic subscription status display
2. Show trial countdown and status
3. Display current tier information
4. Implement basic navigation

### Phase 2: Billing Tiers & Comparison
1. Fetch and display all available tiers
2. Create comparison interface
3. Implement tier selection (UI only initially)
4. Add cost calculation for Professional tier

### Phase 3: Trial Management Integration
1. Add trial warnings and notifications
2. Implement user limit displays
3. Create upgrade prompts and flows
4. Handle trial expiration states

## Success Criteria
- ✅ Admin users can view current subscription status
- ✅ Trial countdown is prominently displayed
- ✅ All billing tiers are clearly presented with pricing
- ✅ User limits are enforced in the UI
- ✅ Professional tier shows accurate per-user pricing
- ✅ Responsive design works on all devices
- ✅ Error states are handled gracefully

## Notes for Implementation
- **Authentication**: All admin billing endpoints require authentication
- **Tenant Context**: Always include the `X-Tenant` header
- **Real-time Updates**: Consider polling trial status for countdown timers
- **Caching**: Cache billing tiers data (it changes infrequently)
- **Progressive Enhancement**: Build features that work without JavaScript

This represents Phase 1 of the billing system frontend. Future phases will add user invitations, Stripe Connect integration, and payment processing.

**Ready to begin implementation!** 🚀
