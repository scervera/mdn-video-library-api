# Frontend Payment Integration Prompt

## 🎯 **Objective**
Implement Stripe payment processing integration for the curriculum library frontend application. The backend is fully configured and ready - you need to implement the frontend payment flow.

## 🔧 **Backend Status**
✅ **Fully Configured & Deployed**
- Stripe API keys configured
- Payment methods controller available
- Subscription controller ready
- Webhook handling fixed
- All endpoints tested and working

## 📋 **Required Implementation**

### **1. Install Stripe Dependencies**
```bash
npm install @stripe/stripe-js @stripe/react-stripe-js
# or
yarn add @stripe/stripe-js @stripe/react-stripe-js
```

### **2. Environment Configuration**
Add to your environment variables:
```env
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_test_... # Get from Stripe Dashboard
REACT_APP_API_BASE_URL=https://curriculum-library-api.cerveras.com
```

### **3. Core Payment Flow Implementation**

#### **Step 1: Payment Method Collection**
Create a component to collect payment information using Stripe Elements:

```typescript
// components/PaymentMethodForm.tsx
import { useState } from 'react';
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js';

interface PaymentMethodFormProps {
  onSuccess: (paymentMethodId: string) => void;
  onError: (error: string) => void;
}

export const PaymentMethodForm = ({ onSuccess, onError }: PaymentMethodFormProps) => {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!stripe || !elements) return;

    setLoading(true);

    try {
      // 1. Create setup intent
      const setupIntentResponse = await fetch(`${process.env.REACT_APP_API_BASE_URL}/api/v1/payment_methods/setup_intent`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${getAuthToken()}`,
          'X-Tenant': getTenantSlug()
        }
      });

      const { client_secret } = await setupIntentResponse.json();

      // 2. Confirm the setup intent
      const { error, setupIntent } = await stripe.confirmCardSetup(client_secret, {
        payment_method: {
          card: elements.getElement(CardElement)!,
          billing_details: {
            name: 'Customer Name', // Get from form
            email: 'customer@example.com' // Get from form
          }
        }
      });

      if (error) {
        onError(error.message);
      } else {
        onSuccess(setupIntent.payment_method);
      }
    } catch (error) {
      onError('Failed to add payment method');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <CardElement
        options={{
          style: {
            base: {
              fontSize: '16px',
              color: '#424770',
              '::placeholder': {
                color: '#aab7c4',
              },
            },
          },
        }}
      />
      <button type="submit" disabled={!stripe || loading}>
        {loading ? 'Adding...' : 'Add Payment Method'}
      </button>
    </form>
  );
};
```

#### **Step 2: Subscription Creation**
Create a component to handle subscription creation:

```typescript
// components/SubscriptionForm.tsx
import { useState } from 'react';

interface SubscriptionFormProps {
  billingTiers: Array<{
    name: string;
    monthly_price: number;
    user_limit: number;
    features: string[];
  }>;
  onSuccess: (subscription: any) => void;
  onError: (error: string) => void;
}

export const SubscriptionForm = ({ billingTiers, onSuccess, onError }: SubscriptionFormProps) => {
  const [selectedTier, setSelectedTier] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubscribe = async () => {
    if (!selectedTier) return;

    setLoading(true);

    try {
      const response = await fetch(`${process.env.REACT_APP_API_BASE_URL}/api/v1/subscriptions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${getAuthToken()}`,
          'X-Tenant': getTenantSlug()
        },
        body: JSON.stringify({
          billing_tier_id: selectedTier
        })
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Failed to create subscription');
      }

      const subscription = await response.json();
      onSuccess(subscription);
    } catch (error) {
      onError(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h3>Choose Your Plan</h3>
      {billingTiers.map((tier) => (
        <div key={tier.name}>
          <input
            type="radio"
            id={tier.name}
            name="tier"
            value={tier.name.toLowerCase()}
            checked={selectedTier === tier.name.toLowerCase()}
            onChange={(e) => setSelectedTier(e.target.value)}
          />
          <label htmlFor={tier.name}>
            {tier.name} - ${tier.monthly_price}/month
            <br />
            Up to {tier.user_limit} users
          </label>
        </div>
      ))}
      <button onClick={handleSubscribe} disabled={!selectedTier || loading}>
        {loading ? 'Creating...' : 'Subscribe'}
      </button>
    </div>
  );
};
```

#### **Step 3: Main Payment Flow Component**
Combine everything into a complete payment flow:

```typescript
// components/PaymentFlow.tsx
import { useState } from 'react';
import { Elements } from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';
import { PaymentMethodForm } from './PaymentMethodForm';
import { SubscriptionForm } from './SubscriptionForm';

const stripePromise = loadStripe(process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY!);

export const PaymentFlow = () => {
  const [step, setStep] = useState<'payment-method' | 'subscription'>('payment-method');
  const [paymentMethodId, setPaymentMethodId] = useState('');
  const [billingTiers, setBillingTiers] = useState([]);
  const [error, setError] = useState('');

  // Load billing tiers on component mount
  useEffect(() => {
    fetchBillingTiers();
  }, []);

  const fetchBillingTiers = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_API_BASE_URL}/api/v1/billing_tiers`, {
        headers: {
          'Authorization': `Bearer ${getAuthToken()}`,
          'X-Tenant': getTenantSlug()
        }
      });
      const data = await response.json();
      setBillingTiers(data.data);
    } catch (error) {
      setError('Failed to load billing tiers');
    }
  };

  const handlePaymentMethodSuccess = (paymentMethodId: string) => {
    setPaymentMethodId(paymentMethodId);
    setStep('subscription');
  };

  const handleSubscriptionSuccess = (subscription: any) => {
    // Handle successful subscription
    console.log('Subscription created:', subscription);
    // Redirect or show success message
  };

  return (
    <Elements stripe={stripePromise}>
      <div>
        {error && <div className="error">{error}</div>}
        
        {step === 'payment-method' && (
          <div>
            <h2>Add Payment Method</h2>
            <PaymentMethodForm
              onSuccess={handlePaymentMethodSuccess}
              onError={setError}
            />
          </div>
        )}

        {step === 'subscription' && (
          <div>
            <h2>Choose Subscription Plan</h2>
            <SubscriptionForm
              billingTiers={billingTiers}
              onSuccess={handleSubscriptionSuccess}
              onError={setError}
            />
          </div>
        )}
      </div>
    </Elements>
  );
};
```

### **4. Utility Functions**
Create helper functions for authentication and tenant context:

```typescript
// utils/api.ts
export const getAuthToken = () => {
  // Get JWT token from localStorage, cookies, or auth context
  return localStorage.getItem('authToken');
};

export const getTenantSlug = () => {
  // Get tenant slug from URL, context, or localStorage
  // Example: acme1.curriculum.cerveras.com -> acme1
  const hostname = window.location.hostname;
  return hostname.split('.')[0];
};

export const apiRequest = async (endpoint: string, options: RequestInit = {}) => {
  const response = await fetch(`${process.env.REACT_APP_API_BASE_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${getAuthToken()}`,
      'X-Tenant': getTenantSlug(),
      ...options.headers,
    },
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'API request failed');
  }

  return response.json();
};
```

### **5. Trial Management**
Implement trial status checking and conversion:

```typescript
// hooks/useTrial.ts
import { useState, useEffect } from 'react';
import { apiRequest } from '../utils/api';

export const useTrial = () => {
  const [trialStatus, setTrialStatus] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchTrialStatus = async () => {
    try {
      const data = await apiRequest('/api/v1/trial/status');
      setTrialStatus(data.data);
    } catch (error) {
      console.error('Failed to fetch trial status:', error);
    } finally {
      setLoading(false);
    }
  };

  const convertTrial = async () => {
    try {
      const data = await apiRequest('/api/v1/trial/convert', {
        method: 'POST'
      });
      setTrialStatus(data.data);
      return data;
    } catch (error) {
      throw error;
    }
  };

  useEffect(() => {
    fetchTrialStatus();
  }, []);

  return { trialStatus, loading, convertTrial, refetch: fetchTrialStatus };
};
```

## 🎨 **UI/UX Requirements**

### **Design Guidelines:**
- Use Stripe's recommended styling for payment forms
- Show clear error messages for payment failures
- Display loading states during API calls
- Provide clear pricing information
- Show trial status prominently
- Use consistent branding with your app

### **User Flow:**
1. **Trial Status Check** - Show current trial status
2. **Payment Method** - Collect card information
3. **Plan Selection** - Choose billing tier
4. **Confirmation** - Review and confirm
5. **Success** - Show confirmation and next steps

## 🔍 **Testing Checklist**

### **Test Cases:**
- [ ] Load billing tiers successfully
- [ ] Add payment method with valid card
- [ ] Handle invalid card information
- [ ] Create subscription successfully
- [ ] Handle subscription creation errors
- [ ] Check trial status
- [ ] Convert trial to paid subscription
- [ ] Handle network errors gracefully
- [ ] Test with different billing tiers
- [ ] Verify tenant isolation (X-Tenant header)

### **Test Cards (Stripe Test Mode):**
- **Success**: `4242424242424242`
- **Decline**: `4000000000000002`
- **Insufficient Funds**: `4000000000009995`
- **Expired Card**: `4000000000000069`

## 🚀 **Deployment Notes**

### **Environment Variables:**
```env
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_test_... # Test key
REACT_APP_API_BASE_URL=https://curriculum-library-api.cerveras.com
```

### **Production Checklist:**
- [ ] Use production Stripe publishable key
- [ ] Test with real payment methods
- [ ] Verify webhook endpoints
- [ ] Test subscription lifecycle
- [ ] Monitor error rates

## 📞 **Support**

### **Backend Endpoints Available:**
- `GET /api/v1/billing_tiers` - List available plans
- `GET /api/v1/trial/status` - Check trial status
- `POST /api/v1/payment_methods/setup_intent` - Create setup intent
- `POST /api/v1/subscriptions` - Create subscription
- `GET /api/v1/subscriptions` - List subscriptions

### **Error Handling:**
The backend returns structured error responses:
```json
{
  "error": {
    "code": "stripe_error",
    "message": "Payment processing failed",
    "details": {
      "stripe_error": "Card declined"
    }
  }
}
```

## 🎯 **Success Criteria**

✅ **Payment Method Collection** - Users can securely add payment methods  
✅ **Subscription Creation** - Users can subscribe to billing tiers  
✅ **Trial Management** - Users can check trial status and convert  
✅ **Error Handling** - Graceful handling of payment failures  
✅ **Tenant Isolation** - Proper X-Tenant header usage  
✅ **Security** - No sensitive data stored in frontend  

**The backend is ready - implement this frontend integration and payment processing will work!** 🚀
