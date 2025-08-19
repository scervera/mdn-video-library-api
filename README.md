# MDN Video Library API

A Rails-based API for managing video curriculum content with multitenant support.

## Architecture

### Multitenancy Strategy

This application uses **path-based multitenancy** with header-based tenant identification:

- **Frontend URLs**: `curriculum.cerveras.com/{tenant-slug}` (e.g., `curriculum.cerveras.com/acme1`)
- **API URLs**: `curriculum-library-api.cerveras.com/api/v1/*` (with `X-Tenant` header)
- **Tenant Identification**: Via `X-Tenant` header containing the tenant slug

### Tenant Isolation

- All data is automatically scoped to the current tenant
- API requests must include the `X-Tenant` header
- Tenant slugs are validated against the database
- Health checks (`/up`) bypass tenant validation

## API Authentication

### JWT Authentication

All API endpoints require JWT authentication using Devise JWT:

```bash
# Login
POST /api/v1/auth/login
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}

# Response includes JWT token
{
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### Using JWT Token

Include the JWT token in the Authorization header:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
X-Tenant: acme1
```

## API Endpoints

### Base URL
```
https://curriculum-library-api.cerveras.com
```

### Required Headers
- `Authorization: Bearer <jwt_token>` (for authenticated endpoints)
- `X-Tenant: <tenant_slug>` (for all endpoints except health checks)

### Authentication Endpoints

```bash
# Login
POST /api/v1/auth/login
Content-Type: application/json

# Logout
POST /api/v1/auth/logout
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Get current user
GET /api/v1/auth/me
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Register new user
POST /api/v1/auth/register
Content-Type: application/json
X-Tenant: <tenant_slug>
```

### Tenant Management

```bash
# Check if tenant slug is available
GET /api/v1/slug_validation/check?slug=acme1

# Register new tenant
POST /api/v1/tenant_registration
Content-Type: application/json

{
  "tenant": {
    "name": "ACME Corporation",
    "slug": "acme1"
  },
  "admin_username": "admin",
  "admin_email": "admin@acme.com",
  "admin_password": "password",
  "admin_first_name": "Admin",
  "admin_last_name": "User"
}
```

### Curriculum Endpoints

```bash
# List all curricula for tenant
GET /api/v1/curricula
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Get specific curriculum
GET /api/v1/curricula/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Enroll in curriculum
POST /api/v1/curricula/{id}/enroll
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Check enrollment status
GET /api/v1/curricula/{id}/enrollment_status
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### Chapter Endpoints

```bash
# List chapters for curriculum
GET /api/v1/curricula/{curriculum_id}/chapters
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Get specific chapter
GET /api/v1/curricula/{curriculum_id}/chapters/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Mark chapter as complete
POST /api/v1/curricula/{curriculum_id}/chapters/{id}/complete
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### Lesson Endpoints

```bash
# List lessons for chapter
GET /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Get specific lesson
GET /api/v1/lessons/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Mark lesson as complete
POST /api/v1/lessons/{id}/complete
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### User Progress Endpoints

```bash
# Get user progress overview
GET /api/v1/user/progress
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Get progress for specific curriculum
GET /api/v1/user/progress/{curriculum_id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### User Notes Endpoints

```bash
# List user notes
GET /api/v1/user/notes
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Create note
POST /api/v1/user/notes
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

{
  "content": "Note content",
  "curriculum_id": 1,
  "chapter_id": 1
}

# Update note
PUT /api/v1/user/notes/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

# Delete note
DELETE /api/v1/user/notes/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### User Highlights Endpoints

```bash
# List user highlights
GET /api/v1/user/highlights
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Create highlight
POST /api/v1/user/highlights
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

{
  "highlighted_text": "Important text",
  "curriculum_id": 1,
  "chapter_id": 1
}

# Update highlight
PUT /api/v1/user/highlights/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

# Delete highlight
DELETE /api/v1/user/highlights/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

### Bookmark Endpoints

```bash
# List bookmarks for lesson
GET /api/v1/lessons/{lesson_id}/bookmarks
Authorization: Bearer <token>
X-Tenant: <tenant_slug>

# Create bookmark
POST /api/v1/lessons/{lesson_id}/bookmarks
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

{
  "title": "Bookmark title",
  "notes": "Bookmark notes",
  "timestamp": 120.5
}

# Update bookmark
PUT /api/v1/lessons/{lesson_id}/bookmarks/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
Content-Type: application/json

# Delete bookmark
DELETE /api/v1/lessons/{lesson_id}/bookmarks/{id}
Authorization: Bearer <token>
X-Tenant: <tenant_slug>
```

## Development Setup

### Prerequisites

- Ruby 3.3.0
- PostgreSQL
- Redis
- Docker (for deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mdn-video-library-api
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Setup database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

5. **Start the server**
   ```bash
   bin/rails server
   ```

### Testing Tenant Isolation

Use the debug script to test tenant isolation:

```bash
bin/rails runner debug_tenants.rb
```

## Deployment

### Production Deployment

The application is deployed using Kamal to `cloud.cerveras.com`.

### Environment Variables

Required environment variables for production:

```bash
# Database
DATABASE_PASSWORD=<password>
POSTGRES_PASSWORD=<password>

# Redis
REDIS_URL=redis://redis:6379/0

# Rails
RAILS_ENV=production
RAILS_MASTER_KEY=<master_key>

# Cloudflare (for future custom domain support)
CLOUDFLARE_DOMAIN=cerveras.com
CLOUDFLARE_DNS_API_TOKEN=<token>
CLOUDFLARE_ZONE_ID=<zone_id>
CLOUDFLARE_STREAM_API_TOKEN=<token>
CLOUDFLARE_STREAM_ACCOUNT_ID=<account_id>
```

## Tenant Management

### Creating Tenants

Tenants are created through the API:

```bash
POST /api/v1/tenant_registration
Content-Type: application/json

{
  "tenant": {
    "name": "Company Name",
    "slug": "company-slug"
  },
  "admin_username": "admin",
  "admin_email": "admin@company.com",
  "admin_password": "password",
  "admin_first_name": "Admin",
  "admin_last_name": "User"
}
```

### Tenant Slug Validation

Tenant slugs must:
- Contain only lowercase letters, numbers, and hyphens
- Be unique across all tenants
- Not conflict with existing slugs

### Tenant Data Isolation

All data is automatically scoped to the current tenant:
- Users can only access data from their tenant
- API responses only include tenant-specific data
- Database queries are automatically filtered by tenant

## Health Checks

The application provides a health check endpoint:

```bash
GET /up
```

This endpoint:
- Returns 200 if the application is healthy
- Returns 500 if there are any exceptions
- Bypasses tenant middleware for load balancer compatibility

## Error Handling

### Common Error Responses

```json
{
  "error": "No token provided"
}
```

```json
{
  "error": "Tenant not found"
}
```

```json
{
  "error": "Unauthorized"
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `422` - Unprocessable Entity
- `500` - Internal Server Error

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

[Add your license information here]
