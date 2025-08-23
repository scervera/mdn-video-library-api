# Backend Agent Request: Implement Invitation Acceptance Endpoints

## 🚨 **Issue Summary**

The user invitation system is missing the **invitation acceptance flow**. Currently, when users click invitation links in emails, they are redirected to the standard login page instead of a dedicated invitation acceptance page. We need to implement the missing backend endpoints to support the complete invitation acceptance flow.

## ✅ **What's Working**

1. **Invitation Creation**: `POST /api/v1/users/invite` ✅
2. **Invitation Listing**: `GET /api/v1/users/invitations` ✅
3. **Invitation Management**: Resend/Cancel ✅
4. **Frontend Invitation Page**: Created at `/invite/[token]` ✅

## ❌ **What's Missing**

1. **Invitation Validation**: `GET /api/v1/users/invitations/validate/{token}` ❌
2. **Invitation Acceptance**: `POST /api/v1/users/invitations/accept/{token}` ❌
3. **User Account Creation**: During invitation acceptance ❌

## 🔍 **Frontend Implementation**

The frontend has been implemented at `src/app/[tenantSlug]/invite/[token]/page.tsx` and expects these endpoints:

### **1. Validate Invitation Token**
```typescript
// GET /api/v1/users/invitations/validate/{token}
interface ValidateInvitationResponse {
  invitation: {
    id: number
    email: string
    role: 'admin' | 'user'
    status: 'pending' | 'accepted' | 'expired' | 'cancelled'
    expires_at: string
    message?: string
    tenant: {
      name: string
      slug: string
    }
  }
}
```

### **2. Accept Invitation**
```typescript
// POST /api/v1/users/invitations/accept/{token}
interface AcceptInvitationRequest {
  username: string
  first_name: string
  last_name: string
  password: string
}

interface AcceptInvitationResponse {
  user: {
    id: number
    email: string
    username: string
    first_name: string
    last_name: string
    role: string
  }
  message: string
}
```

## 🛠️ **Required Backend Implementation**

### **1. Invitation Validation Endpoint**

```ruby
# app/controllers/api/v1/user_invitations_controller.rb
def validate
  invitation = UserInvitation.find_by(token: params[:token])
  
  if invitation.nil?
    render json: { error: 'Invalid invitation token' }, status: :not_found
    return
  end
  
  if invitation.expired?
    render json: { error: 'Invitation has expired' }, status: :unprocessable_entity
    return
  end
  
  if invitation.status != 'pending'
    render json: { error: "Invitation has already been #{invitation.status}" }, status: :unprocessable_entity
    return
  end
  
  render json: {
    invitation: {
      id: invitation.id,
      email: invitation.email,
      role: invitation.role,
      status: invitation.status,
      expires_at: invitation.expires_at,
      message: invitation.message,
      tenant: {
        name: invitation.tenant.name,
        slug: invitation.tenant.slug
      }
    }
  }
end
```

### **2. Invitation Acceptance Endpoint**

```ruby
# app/controllers/api/v1/user_invitations_controller.rb
def accept
  invitation = UserInvitation.find_by(token: params[:token])
  
  if invitation.nil?
    render json: { error: 'Invalid invitation token' }, status: :not_found
    return
  end
  
  if invitation.expired?
    render json: { error: 'Invitation has expired' }, status: :unprocessable_entity
    return
  end
  
  if invitation.status != 'pending'
    render json: { error: "Invitation has already been #{invitation.status}" }, status: :unprocessable_entity
    return
  end
  
  # Create the user account
  user = User.new(
    email: invitation.email,
    username: accept_params[:username],
    first_name: accept_params[:first_name],
    last_name: accept_params[:last_name],
    password: accept_params[:password],
    role: invitation.role,
    tenant: invitation.tenant
  )
  
  if user.save
    # Mark invitation as accepted
    invitation.update(
      status: 'accepted',
      used_at: Time.current,
      user: user
    )
    
    render json: {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role
      },
      message: 'Account created successfully'
    }, status: :created
  else
    render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end
end

private

def accept_params
  params.require(:user).permit(:username, :first_name, :last_name, :password)
end
```

### **3. Routes Configuration**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :user_invitations, only: [:index, :create] do
      member do
        post :resend
        delete :cancel
      end
    end
    
    # Add these new routes
    get 'users/invitations/validate/:token', to: 'user_invitations#validate'
    post 'users/invitations/accept/:token', to: 'user_invitations#accept'
  end
end
```

### **4. Model Updates**

```ruby
# app/models/user_invitation.rb
class UserInvitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :invited_by, class_name: 'User'
  belongs_to :user, optional: true
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin user] }
  validates :token, presence: true, uniqueness: true
  
  before_create :generate_token
  before_create :set_expires_at
  
  def expired?
    expires_at < Time.current
  end
  
  def pending?
    status == 'pending'
  end
  
  def accepted?
    status == 'accepted'
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_expires_at
    self.expires_at = 14.days.from_now
  end
end
```

## 🔧 **Email Template Update**

Update the invitation email template to use the correct frontend URL:

```erb
<!-- app/views/user_invitation_mailer/invite.html.erb -->
<h1>You're invited to join <%= @invitation.tenant.name %></h1>
<p>Hello!</p>
<p>You've been invited to join <%= @invitation.tenant.name %> as a <%= @invitation.role %>.</p>
<% if @invitation.message.present? %>
  <p>Message: <%= @invitation.message %></p>
<% end %>
<p>Click the link below to accept the invitation:</p>
<a href="<%= "#{ENV['FRONTEND_URL']}/#{@invitation.tenant.slug}/invite/#{@invitation.token}" %>">Accept Invitation</a>
<p>This invitation expires on <%= @invitation.expires_at.strftime('%B %d, %Y') %>.</p>
```

## 🧪 **Testing Steps**

### **1. Test Invitation Validation**
```bash
curl -X GET "https://curriculum-library-api.cerveras.com/api/v1/users/invitations/validate/TOKEN_HERE" \
  -H "X-Tenant: acme1"
```

### **2. Test Invitation Acceptance**
```bash
curl -X POST "https://curriculum-library-api.cerveras.com/api/v1/users/invitations/accept/TOKEN_HERE" \
  -H "X-Tenant: acme1" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "newuser",
      "first_name": "John",
      "last_name": "Doe",
      "password": "password123"
    }
  }'
```

## 📋 **Success Criteria**

The invitation acceptance flow is complete when:

1. ✅ Users can click invitation links and see the acceptance page
2. ✅ Invitation validation works correctly
3. ✅ Users can create accounts with the invitation
4. ✅ Invitation status updates to "accepted"
5. ✅ Users are redirected to login after successful acceptance
6. ✅ Invalid/expired invitations show appropriate error messages

## 🔐 **Security Considerations**

1. **Token Validation**: Ensure tokens are secure and unique
2. **Expiration**: Enforce invitation expiration dates
3. **Status Validation**: Prevent double acceptance
4. **Input Validation**: Validate all user input
5. **Tenant Isolation**: Ensure invitations are tenant-scoped

## 📞 **Next Steps**

1. **Backend Team**: Implement the validation and acceptance endpoints
2. **Testing**: Verify the complete invitation flow
3. **Email Configuration**: Ensure emails are being sent with correct URLs
4. **Frontend Testing**: Test the complete user journey

---

**Priority**: High - This completes the core invitation functionality  
**Impact**: Users can now accept invitations and join the platform  
**Estimated Effort**: 4-6 hours for implementation and testing
