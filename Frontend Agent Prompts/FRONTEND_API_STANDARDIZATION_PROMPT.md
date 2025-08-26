# Frontend Agent: API Response Format Standardization

## 🎯 **Important Update**
The backend API has been standardized to use consistent response formats across all endpoints. This is a **breaking change** that requires frontend updates.

## 📋 **New Response Format**

### **All API Responses Now Follow This Structure:**
```typescript
{
  data: T[],                    // The actual data (array for lists, object for single items)
  pagination?: {                // Optional pagination info for list endpoints
    page: number,
    per_page: number,
    total: number,
    total_pages: number
  },
  meta?: {                      // Optional metadata
    token?: string,             // For auth endpoints
    message?: string,           // For action endpoints
    current_subscription?: number, // For subscription endpoints
    statistics?: object,        // For user endpoints
    // ... other context-specific metadata
  }
}
```

### **Error Responses:**
```typescript
{
  error: {
    code: string,               // Error code (e.g., 'validation_error', 'not_found')
    message: string,            // Human-readable error message
    details?: string[]          // Optional validation error details
  }
}
```

## 🔧 **Endpoints That Changed**

### **1. Billing Tiers**
```typescript
// Before
GET /api/v1/billing_tiers
Response: { tiers: BillingTier[], invitation_expiry_days: number }

// After
GET /api/v1/billing_tiers
Response: { data: BillingTier[], meta: { invitation_expiry_days: number } }
```

### **2. Subscriptions**
```typescript
// Before
GET /api/v1/subscriptions
Response: { subscriptions: Subscription[], current_subscription: number }

// After
GET /api/v1/subscriptions
Response: { data: Subscription[], meta: { current_subscription: number } }
```

### **3. Users**
```typescript
// Before
GET /api/v1/users
Response: { users: User[], pagination: PaginationInfo }

// After
GET /api/v1/users
Response: { data: User[], pagination: PaginationInfo }
```

### **4. Trial Status**
```typescript
// Before
GET /api/v1/trial/status
Response: { trial_active: boolean, ... }

// After
GET /api/v1/trial/status
Response: { data: { trial_active: boolean, ... } }
```

### **5. Authentication**
```typescript
// Before
POST /api/v1/auth/login
Response: { user: User, token: string }

// After
POST /api/v1/auth/login
Response: { data: User, meta: { token: string } }
```

## 🚀 **Required Frontend Updates**

### **1. Update TypeScript Types**
```typescript
// New standard response types
interface ApiResponse<T> {
  data: T;
  pagination?: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
  meta?: Record<string, any>;
}

interface ApiError {
  error: {
    code: string;
    message: string;
    details?: string[];
  };
}
```

### **2. Update API Client Methods**
```typescript
// Before
const response = await api.getBillingTiers();
const tiers = response.tiers;
const expiryDays = response.invitation_expiry_days;

// After
const response = await api.getBillingTiers();
const tiers = response.data;
const expiryDays = response.meta.invitation_expiry_days;
```

### **3. Update Error Handling**
```typescript
// Before
if (response.error) {
  console.error(response.error);
}

// After
if (response.error) {
  console.error(response.error.message);
  console.error(response.error.code);
  if (response.error.details) {
    console.error(response.error.details);
  }
}
```

### **4. Update Pagination Handling**
```typescript
// Before
const { users, pagination } = await api.getUsers();
const { page, total_pages } = pagination;

// After
const response = await api.getUsers();
const { data: users, pagination } = response;
const { page, total_pages } = pagination;
```

## 📝 **Error Code Reference**

| Code | Description | Action |
|------|-------------|---------|
| `validation_error` | Form validation failed | Show validation errors |
| `not_found` | Resource not found | Show 404 message |
| `unauthorized` | Authentication required | Redirect to login |
| `forbidden` | Access denied | Show access denied message |
| `invalid_billing_tier` | Invalid billing tier | Show tier selection |
| `subscription_exists` | Already has subscription | Show current subscription |
| `cannot_delete_self` | Cannot delete own account | Show warning message |

## ✅ **Benefits of This Change**

1. **Consistent API**: All endpoints follow the same pattern
2. **Better Error Handling**: Structured error responses with codes
3. **Metadata Support**: Context-specific information in `meta` field
4. **Future-Proof**: Easy to extend without breaking changes
5. **Type Safety**: Better TypeScript support with consistent types

## 🔄 **Migration Steps**

1. **Update TypeScript types** to use new `ApiResponse<T>` interface
2. **Update all API client methods** to extract data from `response.data`
3. **Update pagination handling** to use `response.pagination`
4. **Update metadata handling** to use `response.meta`
5. **Update error handling** to use structured error format
6. **Test all endpoints** to ensure they work with new format

## ⚠️ **Breaking Changes**

This is a **breaking change** that affects all API calls. The frontend will need to be updated to handle the new response format. All existing API client methods will need to be modified to extract data from the `data` field instead of the root response object.

## 📚 **Example Updates**

### **Billing Tiers API**
```typescript
// Before
export const getBillingTiers = async (): Promise<BillingTier[]> => {
  const response = await api.get('/billing_tiers');
  return response.tiers;
};

// After
export const getBillingTiers = async (): Promise<ApiResponse<BillingTier[]>> => {
  const response = await api.get('/billing_tiers');
  return response;
};
```

### **User Login**
```typescript
// Before
export const login = async (credentials: LoginCredentials): Promise<{ user: User, token: string }> => {
  const response = await api.post('/auth/login', credentials);
  return { user: response.user, token: response.token };
};

// After
export const login = async (credentials: LoginCredentials): Promise<ApiResponse<User>> => {
  const response = await api.post('/auth/login', credentials);
  return response;
};
```

The backend is now ready with the standardized API format. Please update the frontend to handle these new response structures.
