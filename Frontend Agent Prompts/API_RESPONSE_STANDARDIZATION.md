# API Response Format Standardization

## 🎯 **Overview**
All API endpoints now use a consistent response format to improve developer experience and maintain a stable API contract.

## 📋 **Standard Response Format**

### **List Endpoints** (`GET` requests returning arrays)
```json
{
  "data": [
    {
      "id": 1,
      "name": "Example",
      // ... other resource properties
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  },
  "meta": {
    // Optional metadata specific to the endpoint
    "current_subscription": 1,
    "invitation_expiry_days": 14
  }
}
```

### **Single Resource Endpoints** (`GET` requests returning single objects)
```json
{
  "data": {
    "id": 1,
    "name": "Example",
    // ... other resource properties
  },
  "meta": {
    // Optional metadata
    "statistics": { ... },
    "message": "Success message"
  }
}
```

### **Action Endpoints** (`POST`, `PUT`, `DELETE` requests)
```json
{
  "data": {
    // Optional: created/updated resource data
    "id": 1,
    "status": "success"
  },
  "meta": {
    "message": "Action completed successfully"
  }
}
```

### **Error Responses**
```json
{
  "error": {
    "code": "validation_error",
    "message": "Validation failed",
    "details": [
      "Email is invalid",
      "Password is too short"
    ]
  }
}
```

## 🔧 **Updated Endpoints**

### **Billing Tiers**
- **Before**: `GET /api/v1/billing_tiers` returned `{ tiers: [...], invitation_expiry_days: 14 }`
- **After**: `GET /api/v1/billing_tiers` returns `{ data: [...], meta: { invitation_expiry_days: 14 } }`

### **Subscriptions**
- **Before**: `GET /api/v1/subscriptions` returned `{ subscriptions: [...], current_subscription: 1 }`
- **After**: `GET /api/v1/subscriptions` returns `{ data: [...], meta: { current_subscription: 1 } }`

### **Users**
- **Before**: `GET /api/v1/users` returned `{ users: [...], pagination: {...} }`
- **After**: `GET /api/v1/users` returns `{ data: [...], pagination: {...} }`

### **Trial Status**
- **Before**: `GET /api/v1/trial/status` returned `{ trial_active: true, ... }`
- **After**: `GET /api/v1/trial/status` returns `{ data: { trial_active: true, ... } }`

### **Authentication**
- **Before**: `POST /api/v1/auth/login` returned `{ user: {...}, token: "..." }`
- **After**: `POST /api/v1/auth/login` returns `{ data: {...}, meta: { token: "..." } }`

## 📝 **Error Code Reference**

| Code | Description | HTTP Status |
|------|-------------|-------------|
| `validation_error` | Form validation failed | 422 |
| `not_found` | Resource not found | 404 |
| `unauthorized` | Authentication required | 401 |
| `forbidden` | Access denied | 403 |
| `invalid_billing_tier` | Invalid billing tier specified | 400 |
| `subscription_exists` | Tenant already has subscription | 422 |
| `trial_not_configured` | Trial tier not configured | 500 |
| `not_in_trial` | Subscription not in trial | 422 |
| `cannot_delete_self` | Cannot delete own account | 422 |
| `cannot_deactivate_self` | Cannot deactivate own account | 422 |

## 🚀 **Frontend Integration**

### **TypeScript Types**
```typescript
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

### **API Client Updates**
```typescript
// Before
const response = await api.getBillingTiers();
const tiers = response.tiers;

// After
const response = await api.getBillingTiers();
const tiers = response.data;
const meta = response.meta;
```

### **Error Handling**
```typescript
// Before
if (response.error) {
  console.error(response.error);
}

// After
if (response.error) {
  console.error(response.error.message);
  console.error(response.error.code);
  console.error(response.error.details);
}
```

## ✅ **Benefits**

1. **Consistent Structure**: All endpoints follow the same response pattern
2. **Better Error Handling**: Structured error responses with codes and details
3. **Metadata Support**: Context-specific information in `meta` field
4. **Pagination Standard**: Consistent pagination format across all list endpoints
5. **Future-Proof**: Easy to extend with new fields without breaking changes

## 🔄 **Migration Guide**

### **For Frontend Developers**
1. Update API client methods to extract data from `response.data`
2. Update pagination handling to use `response.pagination`
3. Update metadata handling to use `response.meta`
4. Update error handling to use structured error format
5. Update TypeScript types to match new response format

### **For Backend Developers**
1. Use `render_list_response()` for list endpoints
2. Use `render_single_response()` for single resource endpoints
3. Use `render_action_response()` for action endpoints
4. Use `render_error_response()` for error responses
5. Use helper methods like `render_validation_errors()` for common cases

## 📚 **Helper Methods Available**

```ruby
# List responses
render_list_response(data, pagination: pagination, meta: meta)

# Single resource responses
render_single_response(data, meta: meta, status: :ok)

# Action responses
render_action_response(data: data, message: message, status: :ok)

# Error responses
render_error_response(error_code: code, message: message, details: details, status: status)

# Common error helpers
render_validation_errors(record)
render_not_found_error(resource_name)
render_unauthorized_error(message)
render_forbidden_error(message)
```

This standardization ensures a consistent and predictable API experience across all endpoints.
