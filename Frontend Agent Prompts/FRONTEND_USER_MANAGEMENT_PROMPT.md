# Frontend Agent Prompt: User Management Implementation

## 🎯 **Objective**
Implement the complete user management interface for the billing system, including user CRUD operations, user invitations, and user statistics. This is **Phase 1** of the billing system implementation.

## ✅ **Backend Status: COMPLETE**
The backend APIs are fully implemented and tested in production. All endpoints are working correctly with proper tenant isolation, authentication, and authorization.

## 📋 **Required Features to Implement**

### **1. User Management Interface**

#### **User List Page (`/admin/users`)**
- **Display**: Table/list of all users in the current tenant
- **Columns**: 
  - Username, Email, Full Name, Role, Status (Active/Inactive)
  - Last Login Date, Created Date
  - Subscription Status, Invitation Status
  - Actions (Edit, Delete, Activate/Deactivate)
- **Features**:
  - Pagination (20 users per page)
  - Search by email/username
  - Filter by role, status, invitation status
  - Sort by any column
  - Bulk actions (activate/deactivate multiple users)

#### **User Detail Page (`/admin/users/:id`)**
- **Display**: Detailed user information
- **Sections**:
  - Basic Info (name, email, role, status)
  - Activity (last login, created date)
  - Subscription info
  - Invitation history
- **Actions**: Edit, Delete, Activate/Deactivate

#### **User Create/Edit Form**
- **Fields**: Username, Email, First Name, Last Name, Role
- **Validation**: Required fields, email format, unique username
- **Actions**: Save, Cancel

### **2. User Invitation System**

#### **Invitation List Page (`/admin/invitations`)**
- **Display**: Table of all invitations
- **Columns**:
  - Email, User Name, Status (Pending/Accepted/Expired/Cancelled)
  - Invited By, Created Date, Expires Date
  - Actions (Resend, Cancel, View Details)
- **Features**:
  - Pagination (20 invitations per page)
  - Filter by status, date range
  - Search by email
  - Sort by any column

#### **Send Invitation Form**
- **Fields**: Email, First Name, Last Name, Role, Message (optional)
- **Validation**: Required fields, email format, unique email
- **Actions**: Send Invitation, Cancel
- **Success**: Show confirmation and redirect to invitation list

#### **Invitation Detail Page (`/admin/invitations/:id`)**
- **Display**: Detailed invitation information
- **Sections**:
  - Invitation details (email, status, expiry)
  - User information (if created)
  - Invitation history (resend count, dates)
- **Actions**: Resend, Cancel, View User

### **3. User Statistics Dashboard**

#### **Statistics Overview (`/admin/dashboard`)**
- **Metrics Cards**:
  - Total Users
  - Active Users
  - Pending Invitations
  - Acceptance Rate
  - Recent Activity (last 30 days)
- **Charts**:
  - User growth over time
  - Invitation acceptance rate
  - User activity by role

### **4. User Profile Management**

#### **Current User Profile (`/profile`)**
- **Display**: Current user's profile information
- **Editable Fields**: First Name, Last Name, Email
- **Read-only**: Username, Role, Created Date, Last Login
- **Actions**: Update Profile, Change Password

## 🔌 **API Integration**

### **Base Configuration**
```typescript
// All API calls must include:
headers: {
  'Authorization': `Bearer ${token}`,
  'X-Tenant': tenantSlug,
  'Content-Type': 'application/json'
}
```

### **User Management APIs**

#### **List Users**
```typescript
GET /api/v1/users?page=1&per_page=20&search=email&role=user&status=active
Response: {
  users: User[],
  pagination: { page, per_page, total, total_pages }
}
```

#### **Get User**
```typescript
GET /api/v1/users/:id
Response: { user: User }
```

#### **Create User**
```typescript
POST /api/v1/users
Body: { username, email, first_name, last_name, role }
Response: { user: User }
```

#### **Update User**
```typescript
PUT /api/v1/users/:id
Body: { first_name, last_name, role }
Response: { user: User }
```

#### **Delete User**
```typescript
DELETE /api/v1/users/:id
Response: { message: "User deleted successfully" }
```

#### **Activate/Deactivate User**
```typescript
POST /api/v1/users/:id/activate
POST /api/v1/users/:id/deactivate
Response: { user: User }
```

#### **User Statistics**
```typescript
GET /api/v1/users/statistics
Response: {
  total_users, active_users, inactive_users,
  users_by_role, recent_users, user_growth_rate
}
```

### **User Invitation APIs**

#### **List Invitations**
```typescript
GET /api/v1/user_invitations?page=1&per_page=20&status=pending
Response: {
  invitations: Invitation[],
  pagination: { page, per_page, total, total_pages }
}
```

#### **Send Invitation**
```typescript
POST /api/v1/user_invitations
Body: { email, first_name, last_name, role, message }
Response: { invitation: Invitation }
```

#### **Resend Invitation**
```typescript
POST /api/v1/user_invitations/:id/resend
Response: { invitation: Invitation, message: "Invitation resent successfully" }
```

#### **Cancel Invitation**
```typescript
DELETE /api/v1/user_invitations/:id
Response: { invitation: Invitation, message: "Invitation cancelled successfully" }
```

#### **Invitation Statistics**
```typescript
GET /api/v1/user_invitations/statistics
Response: {
  total_invitations, pending_invitations, accepted_invitations,
  expired_invitations, cancelled_invitations, recent_invitations,
  acceptance_rate
}
```

## 🎨 **UI/UX Requirements**

### **Design System**
- Use existing design system and components
- Maintain consistency with current billing system UI
- Follow accessibility guidelines (WCAG 2.1 AA)

### **Responsive Design**
- Mobile-first approach
- Tablet and desktop optimized
- Collapsible tables for mobile

### **Loading States**
- Skeleton loaders for lists
- Loading spinners for actions
- Progressive loading for large datasets

### **Error Handling**
- User-friendly error messages
- Retry mechanisms for failed API calls
- Validation feedback on forms

### **Success Feedback**
- Toast notifications for successful actions
- Confirmation dialogs for destructive actions
- Progress indicators for long-running operations

## 🔐 **Security & Permissions**

### **Role-Based Access**
- **Admin Users**: Full access to all user management features
- **Regular Users**: Access only to their own profile
- **Unauthenticated**: Redirect to login

### **Data Protection**
- Mask sensitive information (emails, names) in logs
- Confirm destructive actions
- Rate limiting for invitation sending

## 📱 **Navigation Structure**

```
/admin/
├── dashboard/          # Statistics overview
├── users/             # User list
│   ├── new           # Create user
│   └── [id]          # User detail/edit
├── invitations/       # Invitation list
│   ├── new           # Send invitation
│   └── [id]          # Invitation detail
└── settings/         # Admin settings

/profile/              # Current user profile
```

## 🧪 **Testing Requirements**

### **Unit Tests**
- Component rendering
- Form validation
- API integration
- Error handling

### **Integration Tests**
- User workflow (create → invite → accept)
- Admin permissions
- Tenant isolation

### **E2E Tests**
- Complete user management flow
- Invitation lifecycle
- Cross-tenant isolation

## 📊 **Data Models**

### **User Interface**
```typescript
interface User {
  id: number;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  role: 'admin' | 'user';
  active: boolean;
  created_at: string;
  updated_at: string;
  last_login_at: string | null;
  subscription_status: 'active' | 'none';
  invitation_status: 'pending' | 'accepted';
}
```

### **Invitation Interface**
```typescript
interface Invitation {
  id: number;
  email: string;
  user_id: number | null;
  user: User | null;
  invited_by: User;
  status: 'pending' | 'accepted' | 'cancelled';
  message: string | null;
  expires_at: string;
  created_at: string;
  used_at: string | null;
  cancelled_at: string | null;
  resent_at: string | null;
  resent_count: number;
  token: string;
}
```

## 🚀 **Implementation Priority**

### **Phase 1 (High Priority)**
1. User list page with basic CRUD
2. Send invitation form
3. Invitation list page
4. Basic statistics dashboard

### **Phase 2 (Medium Priority)**
1. User detail/edit pages
2. Advanced filtering and search
3. Bulk actions
4. Enhanced statistics and charts

### **Phase 3 (Low Priority)**
1. Advanced user management features
2. User activity tracking
3. Advanced reporting
4. Performance optimizations

## 🔗 **Integration Points**

### **Existing Components**
- Use existing table components
- Reuse form components
- Leverage existing modal/dialog components
- Use existing notification system

### **State Management**
- Integrate with existing auth context
- Use existing tenant context
- Add user management state
- Cache user and invitation data

### **Routing**
- Add new routes to existing router
- Implement proper route guards
- Handle deep linking
- Add breadcrumb navigation

## 📝 **Documentation Requirements**

### **Code Documentation**
- JSDoc comments for all functions
- TypeScript interfaces for all data models
- README updates for new features
- API integration examples

### **User Documentation**
- Admin user guide
- Feature documentation
- Troubleshooting guide
- FAQ section

## 🎯 **Success Criteria**

### **Functional Requirements**
- ✅ All CRUD operations work correctly
- ✅ Invitation system functions properly
- ✅ Statistics are accurate and real-time
- ✅ Tenant isolation is maintained
- ✅ All permissions are enforced

### **Performance Requirements**
- ✅ Page load times < 2 seconds
- ✅ API response times < 500ms
- ✅ Smooth animations and transitions
- ✅ Efficient data caching

### **User Experience**
- ✅ Intuitive navigation
- ✅ Clear feedback for all actions
- ✅ Responsive design works on all devices
- ✅ Accessibility compliance

## 🔄 **Next Steps After Completion**

Once this implementation is complete, the next phase will be:
- **Phase 2: Payment Integration APIs** (Stripe configuration, payment methods, invoices)
- **Phase 3: Enhanced Features** (Webhooks, advanced billing, reporting)

## 📞 **Support & Questions**

For any questions about the backend APIs or implementation details, refer to:
- API documentation in the codebase
- Test examples in the backend
- Production API endpoints for reference

---

**Ready to implement? Let's build an amazing user management system! 🚀**
