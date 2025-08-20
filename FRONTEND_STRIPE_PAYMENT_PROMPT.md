# Frontend Agent Prompt: Stripe Payment System Implementation

## 🎯 **Objective**
Implement the complete Stripe payment system UI for the Next.js frontend application, integrating with the newly deployed backend APIs.

## ✅ **Backend Status: COMPLETE**
The backend has been fully implemented and deployed with the following features:
- ✅ Stripe customer management API
- ✅ Payment methods API (add, update, delete, set default)
- ✅ Payment intents for secure transactions
- ✅ Invoice management and payment processing
- ✅ Email system with user invitations
- ✅ Multi-tenant architecture with Stripe Connect

## 🏗️ **System Architecture**

### **Multi-Tenant Payment Model**
- **Tenant Stripe Connect Accounts**: Each tenant has their own Stripe Connect account
- **User Stripe Customers**: Individual users have Stripe customer IDs linked to their accounts
- **Two Billing Scenarios**:
  1. **Professional Tier**: Tenant pays monthly, users pay individual subscriptions
  2. **Basic/Enterprise Tiers**: Tenant pays monthly, users access via invitations

### **API Base URL**
```
https://curriculum-library-api.cerveras.com/api/v1
```

### **Authentication**
- JWT tokens in Authorization header
- X-Tenant header required for all API calls
- Admin/owner permissions for sensitive operations

## 🚀 **Implementation Requirements**

### **Phase 1: Stripe Connect Setup (HIGH Priority)**

#### **1.1 Tenant Stripe Connect Integration**
- **Stripe Connect OAuth Flow**: Implement OAuth flow for tenants to connect their Stripe accounts
- **Connect Status Dashboard**: Show connection status, account details, and onboarding progress
- **Account Verification**: Display account verification status and requirements

**API Endpoints:**
```typescript
// Stripe Connect Account Status
GET /api/v1/stripe_connect/status
POST /api/v1/stripe_connect/authorize
GET /api/v1/stripe_connect/account_details
```

#### **1.2 Stripe Connect UI Components**
```typescript
// Components to create:
- StripeConnectSetup.tsx
- StripeConnectStatus.tsx
- StripeConnectDashboard.tsx
- StripeAccountVerification.tsx
```

### **Phase 2: Customer Management (HIGH Priority)**

#### **2.1 Customer Management Interface**
- **Customer List**: Display all customers for the tenant
- **Customer Details**: Show customer information, payment methods, subscriptions
- **Customer Creation**: Create new customers from existing users

**API Endpoints:**
```typescript
// Customer Management
GET /api/v1/stripe_customers
POST /api/v1/stripe_customers
GET /api/v1/stripe_customers/:id
PATCH /api/v1/stripe_customers/:id
DELETE /api/v1/stripe_customers/:id
GET /api/v1/stripe_customers/:id/payment_methods
GET /api/v1/stripe_customers/:id/subscriptions
```

#### **2.2 Customer UI Components**
```typescript
// Components to create:
- CustomerList.tsx
- CustomerDetails.tsx
- CustomerForm.tsx
- CustomerPaymentMethods.tsx
- CustomerSubscriptions.tsx
```

### **Phase 3: Payment Methods (HIGH Priority)**

#### **3.1 Payment Method Management**
- **Add Payment Methods**: Secure card collection using Stripe Elements
- **Payment Method List**: Display all payment methods for a customer
- **Set Default**: Allow setting default payment method
- **Delete Payment Methods**: Remove payment methods with confirmation

**API Endpoints:**
```typescript
// Payment Methods
GET /api/v1/payment_methods
POST /api/v1/payment_methods
GET /api/v1/payment_methods/:id
PATCH /api/v1/payment_methods/:id
DELETE /api/v1/payment_methods/:id
POST /api/v1/payment_methods/:id/set_default
POST /api/v1/payment_methods/setup_intent
```

#### **3.2 Payment Method UI Components**
```typescript
// Components to create:
- PaymentMethodList.tsx
- AddPaymentMethod.tsx
- PaymentMethodCard.tsx
- SetupIntentForm.tsx
- PaymentMethodActions.tsx
```

### **Phase 4: Payment Processing (HIGH Priority)**

#### **4.1 Payment Intents**
- **Create Payment Intents**: For one-time payments and subscription payments
- **Confirm Payments**: Handle 3D Secure authentication
- **Payment Status**: Real-time payment status updates

**API Endpoints:**
```typescript
// Payment Intents
GET /api/v1/payment_intents
POST /api/v1/payment_intents
GET /api/v1/payment_intents/:id
PATCH /api/v1/payment_intents/:id
POST /api/v1/payment_intents/:id/confirm
POST /api/v1/payment_intents/:id/cancel
POST /api/v1/payment_intents/subscription_payment
```

#### **4.2 Payment Processing UI Components**
```typescript
// Components to create:
- PaymentIntentForm.tsx
- PaymentConfirmation.tsx
- PaymentStatus.tsx
- SubscriptionPayment.tsx
- PaymentError.tsx
```

### **Phase 5: Invoice Management (MEDIUM Priority)**

#### **5.1 Invoice Interface**
- **Invoice List**: Display all invoices for customers
- **Invoice Details**: Show invoice line items, payment status, download PDF
- **Invoice Actions**: Pay, void, mark uncollectible, send invoice

**API Endpoints:**
```typescript
// Invoices
GET /api/v1/invoices
POST /api/v1/invoices
GET /api/v1/invoices/:id
PATCH /api/v1/invoices/:id
POST /api/v1/invoices/:id/pay
POST /api/v1/invoices/:id/void
POST /api/v1/invoices/:id/mark_uncollectible
POST /api/v1/invoices/:id/send
GET /api/v1/invoices/upcoming
```

#### **5.2 Invoice UI Components**
```typescript
// Components to create:
- InvoiceList.tsx
- InvoiceDetails.tsx
- InvoiceActions.tsx
- InvoicePDF.tsx
- UpcomingInvoice.tsx
```

## 🎨 **UI/UX Requirements**

### **Design System**
- **Consistent with existing design**: Match current UI patterns and color scheme
- **Responsive design**: Mobile-first approach
- **Loading states**: Skeleton loaders and progress indicators
- **Error handling**: User-friendly error messages and recovery options

### **Stripe Elements Integration**
```typescript
// Required Stripe Elements:
- CardElement (for payment methods)
- PaymentElement (for payment intents)
- AddressElement (for billing details)
- LinkAuthenticationElement (for Link payments)
```

### **Real-time Updates**
- **WebSocket integration**: For payment status updates
- **Optimistic updates**: Immediate UI feedback
- **Background sync**: Sync data when connection restored

## 🔐 **Security Requirements**

### **PCI Compliance**
- **Never store card data**: Use Stripe Elements for secure collection
- **Token-based payments**: Use payment method tokens
- **Secure communication**: HTTPS only, proper CORS configuration

### **Authentication & Authorization**
- **JWT token management**: Secure token storage and refresh
- **Role-based access**: Admin/owner permissions for sensitive operations
- **Tenant isolation**: Ensure data is properly scoped

## 📱 **User Experience Flow**

### **Tenant Onboarding Flow**
1. **Sign up** → Create tenant account
2. **Connect Stripe** → OAuth flow to connect Stripe account
3. **Verify account** → Complete Stripe account verification
4. **Choose billing tier** → Select subscription plan
5. **Invite users** → Send user invitations

### **User Payment Flow (Professional Tier)**
1. **Accept invitation** → User accepts tenant invitation
2. **Create customer** → Backend creates Stripe customer
3. **Add payment method** → User adds payment method
4. **Subscribe** → User subscribes to individual plan
5. **Access content** → User gains access to curriculum

### **Payment Processing Flow**
1. **Select payment method** → User chooses payment method
2. **Create payment intent** → Backend creates payment intent
3. **Confirm payment** → User confirms payment (3D Secure if needed)
4. **Process payment** → Stripe processes the payment
5. **Update status** → UI updates with payment status

## 🧪 **Testing Requirements**

### **Stripe Test Mode**
- **Test cards**: Use Stripe test card numbers
- **Test webhooks**: Set up webhook testing
- **Test accounts**: Use Stripe Connect test accounts

### **Error Scenarios**
- **Network failures**: Handle API timeouts and retries
- **Payment failures**: Handle declined payments gracefully
- **Authentication errors**: Handle token expiration
- **Stripe errors**: Display user-friendly error messages

## 📊 **Analytics & Monitoring**

### **Payment Analytics**
- **Conversion tracking**: Track payment success rates
- **Revenue metrics**: Monitor subscription revenue
- **User behavior**: Track payment method preferences

### **Error Monitoring**
- **Payment failures**: Monitor and alert on payment issues
- **API errors**: Track API error rates
- **User feedback**: Collect user feedback on payment experience

## 🔧 **Technical Implementation**

### **State Management**
```typescript
// Redux/Zustand stores needed:
- stripeConnectStore
- customerStore
- paymentMethodStore
- paymentIntentStore
- invoiceStore
```

### **API Integration**
```typescript
// API service classes:
- StripeConnectService
- CustomerService
- PaymentMethodService
- PaymentIntentService
- InvoiceService
```

### **TypeScript Types**
```typescript
// Define comprehensive types for:
- StripeCustomer
- PaymentMethod
- PaymentIntent
- Invoice
- StripeConnectAccount
```

## 🚀 **Deployment Checklist**

### **Environment Configuration**
- **Stripe publishable keys**: Configure for each environment
- **Webhook endpoints**: Set up webhook URLs
- **CORS configuration**: Allow frontend domains
- **API base URLs**: Configure for dev/staging/production

### **Feature Flags**
- **Stripe Connect**: Enable/disable Stripe Connect features
- **Payment methods**: Enable/disable payment method management
- **Invoices**: Enable/disable invoice features

## 📋 **Success Criteria**

### **Functional Requirements**
- ✅ Users can connect Stripe accounts via OAuth
- ✅ Users can add and manage payment methods
- ✅ Users can process payments securely
- ✅ Users can view and manage invoices
- ✅ Admin users can manage customer data
- ✅ All operations respect tenant isolation

### **Performance Requirements**
- ✅ Payment processing under 5 seconds
- ✅ UI updates within 1 second
- ✅ 99.9% uptime for payment operations
- ✅ Mobile-responsive design

### **Security Requirements**
- ✅ PCI DSS compliance
- ✅ Secure token handling
- ✅ Proper error handling
- ✅ No sensitive data in logs

## 🎯 **Priority Order**

1. **HIGH**: Stripe Connect setup and customer management
2. **HIGH**: Payment methods and payment processing
3. **MEDIUM**: Invoice management and analytics
4. **LOW**: Advanced features and optimizations

## 📞 **Support & Documentation**

### **Developer Resources**
- **Stripe Documentation**: https://stripe.com/docs
- **Stripe Elements**: https://stripe.com/docs/stripe-js
- **Stripe Connect**: https://stripe.com/docs/connect
- **API Reference**: Backend API documentation

### **Testing Resources**
- **Stripe Test Cards**: https://stripe.com/docs/testing
- **Stripe CLI**: For webhook testing
- **Stripe Dashboard**: For monitoring and debugging

---

**Ready to implement? The backend is fully deployed and ready for frontend integration! 🚀**
