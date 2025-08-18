# MDN Video Library API

A Rails API for managing video-based learning curricula, lessons, and user progress tracking with **multitenancy support**.

## Features

- **Multitenancy**: Complete tenant isolation with subdomain-based routing
- **Curriculum Management**: Create and manage learning paths with chapters and lessons
- **User Progress Tracking**: Monitor user completion of chapters and lessons
- **Notes & Highlights**: Users can take notes and highlight content
- **Authentication**: JWT-based authentication using Devise
- **API-First**: RESTful API designed for frontend consumption
- **Tenant Branding**: Customizable branding per tenant
- **Cloudflare Stream Integration**: Video hosting and streaming

## Multitenancy Architecture

This application supports multiple tenants with complete data isolation:

### Tenant Structure
- **Subdomain-based routing**: Each tenant has a unique subdomain (e.g., `acme1.curriculum-library-api.cerveras.com`)
- **Data isolation**: All data is scoped to the current tenant
- **Custom branding**: Each tenant can customize colors, logos, and company information
- **Independent user management**: Users are isolated per tenant

### Demo Tenants
The application comes with three demo tenants:

1. **ACME Corporation** (`acme1`)
   - ACME Business Fundamentals
   - ACME Innovation Workshop

2. **TechStart Inc** (`acme2`)
   - TechStart Programming Bootcamp
   - TechStart Product Management

3. **Global Solutions** (`acme3`)
   - Global Solutions International Business
   - Global Solutions Cultural Intelligence

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User sign in
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/logout` - User sign out
- `GET /api/v1/auth/me` - Get current user info

### Curricula
- `GET /api/v1/curricula` - List all curricula for current tenant
- `GET /api/v1/curricula/:id` - Get curriculum details with progress
- `POST /api/v1/curricula/:id/enroll` - Enroll in a curriculum
- `GET /api/v1/curricula/:id/enrollment_status` - Check enrollment status

### Chapters
- `GET /api/v1/curricula/:curriculum_id/chapters` - List chapters for a curriculum
- `GET /api/v1/chapters/:id` - Get chapter details
- `POST /api/v1/chapters/:id/complete` - Mark chapter as complete

### Lessons
- `GET /api/v1/chapters/:chapter_id/lessons` - List lessons for a chapter
- `GET /api/v1/lessons/:id` - Get lesson details
- `POST /api/v1/lessons/:id/complete` - Mark lesson as complete

### User Progress
- `GET /api/v1/curricula/user/progress` - Get user progress for all curricula
- `GET /api/v1/user/progress` - Get user progress for current tenant

### Notes & Highlights
- `GET /api/v1/user/notes` - Get user notes for current tenant
- `POST /api/v1/user/notes` - Create a new note
- `PUT /api/v1/user/notes/:id` - Update a note
- `DELETE /api/v1/user/notes/:id` - Delete a note

- `GET /api/v1/user/highlights` - Get user highlights for current tenant
- `POST /api/v1/user/highlights` - Create a new highlight
- `PUT /api/v1/user/highlights/:id` - Update a highlight
- `DELETE /api/v1/user/highlights/:id` - Delete a highlight

### Bookmarks
- `GET /api/v1/lessons/:lesson_id/bookmarks` - Get bookmarks for a lesson
- `POST /api/v1/lessons/:lesson_id/bookmarks` - Create a bookmark
- `PUT /api/v1/bookmarks/:id` - Update a bookmark
- `DELETE /api/v1/bookmarks/:id` - Delete a bookmark

### Tenant Management
- `GET /tenant/new` - Tenant registration form
- `POST /tenant` - Create new tenant
- `GET /tenant/settings` - Tenant settings
- `PATCH /tenant/settings` - Update tenant settings
- `GET /branding.css` - Get tenant-specific CSS

## Quick Start

### Prerequisites
- Ruby 3.3.0
- PostgreSQL
- Redis
- Node.js (for asset compilation)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd mdn-video-library-api
```

2. Install dependencies
```bash
bundle install
```

3. Setup database
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

4. Start the server
```bash
bin/dev
```

The API will be available at `http://localhost:3000`

### Testing Tenant Isolation

Use the debug script to verify tenant isolation:
```bash
ruby debug_tenants.rb
```

### Demo Credentials

Each tenant has demo users:

**ACME Corporation** (`acme1.localhost:3000`)
- Admin: `admin_acme1` / `password`
- Demo: `demo_acme1` / `password`

**TechStart Inc** (`acme2.localhost:3000`)
- Admin: `admin_acme2` / `password`
- Demo: `demo_acme2` / `password`

**Global Solutions** (`acme3.localhost:3000`)
- Admin: `admin_acme3` / `password`
- Demo: `demo_acme3` / `password`

### Testing

Run the test suite:
```bash
bin/rails test
```

## Deployment

This application uses [Kamal](https://kamal-deploy.org/) for deployment. See [KAMAL_DEPLOYMENT.md](KAMAL_DEPLOYMENT.md) for detailed deployment instructions.

### Quick Deployment Commands

```bash
# Build Docker image
bundle exec kamal build

# Deploy to production
bundle exec kamal deploy

# Check status
bundle exec kamal app status

# View logs
bundle exec kamal logs
```

## Development

### Database Schema

The application uses several key models with tenant isolation:

- **Tenant**: Multitenancy configuration and branding
- **User**: Authentication and user management (scoped to tenant)
- **Curriculum**: Learning paths containing chapters (scoped to tenant)
- **Chapter**: Sections within a curriculum containing lessons (scoped to tenant)
- **Lesson**: Individual learning units (scoped to tenant)
- **UserProgress**: Tracks user enrollment and chapter completion (scoped to tenant)
- **LessonProgress**: Tracks individual lesson completion (scoped to tenant)
- **UserNote**: User-generated notes for content (scoped to tenant)
- **UserHighlight**: User highlights of content (scoped to tenant)
- **Bookmark**: Video bookmarks with timestamps (scoped to tenant)

### Key Relationships

- All models are scoped to a Tenant
- A User belongs to one Tenant
- A User can enroll in multiple Curricula within their tenant
- A Curriculum contains multiple Chapters
- A Chapter contains multiple Lessons
- UserProgress tracks enrollment and chapter completion
- LessonProgress tracks individual lesson completion
- Notes and Highlights are associated with specific chapters and curricula

### Tenant Middleware

The application uses middleware to detect the current tenant based on the subdomain:

```ruby
# lib/tenant_middleware.rb
class TenantMiddleware
  def call(env)
    request = Rack::Request.new(env)
    subdomain = extract_subdomain(request.host)
    
    if subdomain.present? && subdomain != 'www'
      tenant = Tenant.find_by(subdomain: subdomain)
      if tenant
        Current.tenant = tenant
        @app.call(env)
      else
        [404, {'Content-Type' => 'text/html'}, ['Tenant not found']]
      end
    else
      @app.call(env)
    end
  ensure
    Current.tenant = nil
  end
end
```

### Tenant Isolation

All models inherit from `ApplicationRecord` which includes a default scope for tenant isolation:

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Scope all queries to current tenant (only for models that have tenant_id column)
  default_scope { where(tenant_id: Current.tenant.id) if Current.tenant && column_names.include?('tenant_id') }

  # Ensure tenant is set on creation
  before_create :set_tenant

  private

  def set_tenant
    self.tenant_id = Current.tenant.id if respond_to?(:tenant_id=) && tenant_id.nil? && Current.tenant
  end
end
```

## Documentation

- [Multitenant Implementation](MULTITENANT_IMPLEMENTATION.md) - Detailed multitenancy guide
- [API Testing with Postman](POSTMAN_API_TESTING.md) - API testing guide
- [Cloudflare Stream Integration](CLOUDFLARE_STREAM_INTEGRATION.md) - Video streaming setup
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Production deployment
- [Backup System](COMPLETE_BACKUP_SYSTEM.md) - Database backup and restore

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.
