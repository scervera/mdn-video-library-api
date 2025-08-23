# Frontend Invitation Acceptance Integration Guide

## ✅ **Implementation Complete**

The backend invitation acceptance endpoints have been successfully implemented and deployed to production. The complete invitation flow is now functional.

## 🚀 **New Endpoints Available**

### **1. Validate Invitation Token**
```
GET /api/v1/users/invitations/validate/{token}
```

**Purpose**: Validate an invitation token and return invitation details

**Authentication**: None required

**Response**:
```json
{
  "invitation": {
    "id": 2,
    "email": "user@example.com",
    "role": "user",
    "status": "pending",
    "expires_at": "2025-09-06T00:03:43.000Z",
    "message": "Optional message from inviter",
    "tenant": {
      "name": "Acme Corporation",
      "slug": "acme1"
    }
  }
}
```

**Error Responses**:
- `404 Not Found`: Invalid invitation token
- `422 Unprocessable Entity`: Invitation expired or already used

### **2. Accept Invitation**
```
POST /api/v1/users/invitations/accept/{token}
```

**Purpose**: Accept an invitation and create a new user account

**Authentication**: None required

**Request Body**:
```json
{
  "user": {
    "username": "newuser",
    "first_name": "John",
    "last_name": "Doe",
    "password": "securepassword123"
  }
}
```

**Response**:
```json
{
  "user": {
    "id": 15,
    "email": "user@example.com",
    "username": "newuser",
    "first_name": "John",
    "last_name": "Doe",
    "role": "user"
  },
  "message": "Account created successfully"
}
```

**Error Responses**:
- `404 Not Found`: Invalid invitation token
- `422 Unprocessable Entity`: Invitation expired, already used, or validation errors

## 🔗 **Email Integration**

### **Updated Email URLs**
Invitation emails now contain the correct frontend URL format:
```
https://curriculum.cerveras.com/{tenant_slug}/invite/{token}
```

**Example**:
```
https://curriculum.cerveras.com/acme1/invite/9dnsIUdPTcKtrmSpwdXcWbrpPbK1kA2Cybgi-z4eEJw
```

## 🧪 **Testing the Endpoints**

### **1. Test Invitation Validation**
```bash
curl -X GET "https://curriculum-library-api.cerveras.com/api/v1/users/invitations/validate/9dnsIUdPTcKtrmSpwdXcWbrpPbK1kA2Cybgi-z4eEJw" \
  -H "X-Tenant: acme1"
```

### **2. Test Invitation Acceptance**
```bash
curl -X POST "https://curriculum-library-api.cerveras.com/api/v1/users/invitations/accept/9dnsIUdPTcKtrmSpwdXcWbrpPbK1kA2Cybgi-z4eEJw" \
  -H "X-Tenant: acme1" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "testuser",
      "first_name": "Test",
      "last_name": "User",
      "password": "password123"
    }
  }'
```

## 🔄 **Complete User Journey**

### **1. Admin Sends Invitation**
- Admin creates invitation via frontend
- Backend creates invitation record and sends email
- Email contains invitation link with correct format

### **2. User Receives Email**
- User clicks invitation link
- Frontend navigates to `/invite/[token]` page
- Frontend calls validation endpoint to verify token

### **3. User Accepts Invitation**
- Frontend displays invitation details
- User fills out account creation form
- Frontend calls acceptance endpoint
- Backend creates user account and marks invitation as accepted

### **4. User Account Created**
- User can now log in with their new credentials
- Invitation status changes to "accepted"
- User has the role specified in the invitation

## 🛡️ **Security Features**

### **Token Security**
- Tokens are cryptographically secure (32-byte random)
- Tokens are unique across all tenants
- Tokens expire after 14 days (configurable)

### **Validation Checks**
- Token existence validation
- Expiration date validation
- Status validation (pending only)
- Tenant isolation

### **Input Validation**
- Username uniqueness within tenant
- Email format validation
- Password strength requirements
- Required field validation

## 📊 **Database Schema**

### **UserInvitation Model**
```ruby
class UserInvitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :invited_by, class_name: 'User'
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  def expired?
    expires_at <= Time.current
  end
end
```

## 🔧 **Configuration**

### **Invitation Expiry**
Invitation expiry is configured in `config/billing_tiers.json`:
```json
{
  "invitation_expiry_days": 14
}
```

### **Email Configuration**
Email delivery is configured via SMTP:
- **Server**: smtp-relay.brevo.com
- **Port**: 587
- **Authentication**: PLAIN
- **From**: noreply@cerveras.com

## 🎯 **Success Criteria Met**

✅ **Invitation validation works correctly**
✅ **Users can create accounts with invitations**
✅ **Invitation status updates to "accepted"**
✅ **Email delivery is working via SMTP**
✅ **Frontend URLs are correctly formatted**
✅ **Security validation is in place**
✅ **Tenant isolation is enforced**

## 📞 **Next Steps for Frontend**

1. **Test the complete flow** with real invitation tokens
2. **Verify email delivery** to ensure users receive invitations
3. **Test error handling** for expired/invalid tokens
4. **Monitor user acceptance rates** via the statistics endpoint

## 🚨 **Important Notes**

- **No Authentication Required**: Both endpoints work without authentication
- **Tenant Isolation**: Invitations are scoped to specific tenants
- **Email Delivery**: Uses SMTP for reliable delivery
- **Token Security**: Tokens are secure and expire automatically
- **User Creation**: Creates active user accounts immediately upon acceptance

---

**Status**: ✅ **COMPLETE** - Ready for frontend integration  
**Deployment**: ✅ **LIVE** - All endpoints deployed to production  
**Testing**: ✅ **VERIFIED** - Endpoints tested and working
