# API Documentation

## Overview

The MDN Video Library API is a RESTful API that supports multitenancy through subdomain-based routing. All endpoints are scoped to the current tenant, ensuring complete data isolation between tenants.

## Base URL

The API base URL depends on the tenant subdomain:

- **ACME Corporation**: `https://acme1.curriculum-library-api.cerveras.com`
- **TechStart Inc**: `https://acme2.curriculum-library-api.cerveras.com`
- **Global Solutions**: `https://acme3.curriculum-library-api.cerveras.com`

For development: `http://{subdomain}.localhost:3000`

## Authentication

All API endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Getting a JWT Token

**Login**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password"
}
```

**Response**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "demo_user",
    "first_name": "Demo",
    "last_name": "User",
    "role": "user"
  }
}
```

## API Endpoints

### Authentication

#### Login
```http
POST /api/v1/auth/login
```

**Request Body**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

#### Register
```http
POST /api/v1/auth/register
```

**Request Body**
```json
{
  "email": "newuser@example.com",
  "password": "password",
  "password_confirmation": "password",
  "username": "newuser",
  "first_name": "New",
  "last_name": "User"
}
```

#### Logout
```http
POST /api/v1/auth/logout
```

#### Get Current User
```http
GET /api/v1/auth/me
```

### Curricula

#### List Curricula
```http
GET /api/v1/curricula
```

**Response**
```json
[
  {
    "id": 1,
    "title": "ACME Business Fundamentals",
    "description": "Essential business practices and corporate leadership for ACME Corporation employees.",
    "order_index": 1,
    "published": true,
    "enrolled": false,
    "total_chapters": 2,
    "completed_chapters": 0
  }
]
```

#### Get Curriculum Details
```http
GET /api/v1/curricula/:id
```

**Response**
```json
{
  "id": 1,
  "title": "ACME Business Fundamentals",
  "description": "Essential business practices and corporate leadership for ACME Corporation employees.",
  "order_index": 1,
  "published": true,
  "enrolled": true,
  "total_chapters": 2,
  "completed_chapters": 1,
  "chapters": [
    {
      "id": 1,
      "title": "Corporate Strategy",
      "description": "Strategic planning and corporate governance principles.",
      "duration": "2 hours",
      "order_index": 1,
      "published": true,
      "completed": true,
      "completed_at": "2024-01-15T10:30:00Z",
      "total_lessons": 2,
      "completed_lessons": 2,
      "isLocked": false
    }
  ]
}
```

#### Enroll in Curriculum
```http
POST /api/v1/curricula/:id/enroll
```

**Response**
```json
{
  "message": "Successfully enrolled in curriculum",
  "curriculum_id": 1,
  "curriculum_title": "ACME Business Fundamentals"
}
```

#### Check Enrollment Status
```http
GET /api/v1/curricula/:id/enrollment_status
```

**Response**
```json
{
  "curriculum_id": 1,
  "curriculum_title": "ACME Business Fundamentals",
  "enrolled": true,
  "enrollment_date": "2024-01-15T10:00:00Z"
}
```

### Chapters

#### List Chapters for Curriculum
```http
GET /api/v1/curricula/:curriculum_id/chapters
```

#### Get Chapter Details
```http
GET /api/v1/chapters/:id
```

#### Complete Chapter
```http
POST /api/v1/chapters/:id/complete
```

### Lessons

#### List Lessons for Chapter
```http
GET /api/v1/chapters/:chapter_id/lessons
```

#### Get Lesson Details
```http
GET /api/v1/lessons/:id
```

**Response**
```json
{
  "id": 1,
  "title": "Strategic Planning Fundamentals",
  "description": "Core principles of strategic planning and execution",
  "content_type": "video",
  "content": "This lesson covers the fundamental principles of strategic planning in corporate environments.",
  "cloudflare_stream_id": "73cb888469576ace114104f131e8c6c2",
  "order_index": 1,
  "published": true,
  "completed": false,
  "chapter": {
    "id": 1,
    "title": "Corporate Strategy"
  }
}
```

#### Complete Lesson
```http
POST /api/v1/lessons/:id/complete
```

### User Progress

#### Get User Progress
```http
GET /api/v1/user/progress
```

**Response**
```json
{
  "curricula": [
    {
      "id": 1,
      "title": "ACME Business Fundamentals",
      "enrolled": true,
      "total_chapters": 2,
      "completed_chapters": 1,
      "progress_percentage": 50
    }
  ],
  "total_curricula": 1,
  "total_enrolled": 1,
  "total_completed": 0
}
```

### Notes

#### List User Notes
```http
GET /api/v1/user/notes
```

**Response**
```json
[
  {
    "id": 1,
    "content": "This is a great introduction to ACME Business Fundamentals. I learned a lot about the core concepts.",
    "chapter": {
      "id": 1,
      "title": "Corporate Strategy"
    },
    "curriculum": {
      "id": 1,
      "title": "ACME Business Fundamentals"
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

#### Create Note
```http
POST /api/v1/user/notes
```

**Request Body**
```json
{
  "content": "This is an important concept to remember.",
  "chapter_id": 1,
  "curriculum_id": 1
}
```

#### Update Note
```http
PUT /api/v1/user/notes/:id
```

**Request Body**
```json
{
  "content": "Updated note content."
}
```

#### Delete Note
```http
DELETE /api/v1/user/notes/:id
```

### Highlights

#### List User Highlights
```http
GET /api/v1/user/highlights
```

**Response**
```json
[
  {
    "id": 1,
    "highlighted_text": "ACME Business Fundamentals provides essential knowledge for ACME Corporation employees.",
    "chapter": {
      "id": 1,
      "title": "Corporate Strategy"
    },
    "curriculum": {
      "id": 1,
      "title": "ACME Business Fundamentals"
    },
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

#### Create Highlight
```http
POST /api/v1/user/highlights
```

**Request Body**
```json
{
  "highlighted_text": "Important text to highlight",
  "chapter_id": 1,
  "curriculum_id": 1
}
```

#### Update Highlight
```http
PUT /api/v1/user/highlights/:id
```

#### Delete Highlight
```http
DELETE /api/v1/user/highlights/:id
```

### Bookmarks

#### List Bookmarks for Lesson
```http
GET /api/v1/lessons/:lesson_id/bookmarks
```

**Response**
```json
[
  {
    "id": 1,
    "title": "Key Concept",
    "notes": "Important point about Strategic Planning Fundamentals",
    "timestamp": 120.5,
    "lesson": {
      "id": 1,
      "title": "Strategic Planning Fundamentals"
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

#### Create Bookmark
```http
POST /api/v1/lessons/:lesson_id/bookmarks
```

**Request Body**
```json
{
  "title": "Important Moment",
  "notes": "Need to review this section",
  "timestamp": 180.0
}
```

#### Update Bookmark
```http
PUT /api/v1/bookmarks/:id
```

**Request Body**
```json
{
  "title": "Updated Title",
  "notes": "Updated notes",
  "timestamp": 200.0
}
```

#### Delete Bookmark
```http
DELETE /api/v1/bookmarks/:id
```

### Tenant Management

#### Get Tenant Branding CSS
```http
GET /branding.css
```

**Response**
```css
:root {
  --primary-color: #3B82F6;
  --secondary-color: #1F2937;
  --accent-color: #F59E0B;
}

.brand-logo {
  background-image: url('https://example.com/logo.png');
}
```

## Error Responses

### Standard Error Format
```json
{
  "error": "Error message description"
}
```

### Common HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Access denied
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server error

### Example Error Responses

**Authentication Error**
```json
{
  "error": "No token provided"
}
```

**Validation Error**
```json
{
  "error": "Validation failed",
  "details": {
    "email": ["is invalid"],
    "password": ["is too short (minimum is 6 characters)"]
  }
}
```

**Tenant Not Found**
```json
{
  "error": "Tenant not found"
}
```

## Rate Limiting

API requests are rate-limited per tenant to ensure fair usage:

- **Authentication endpoints**: 10 requests per minute
- **General API endpoints**: 100 requests per minute
- **File upload endpoints**: 20 requests per minute

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248600
```

## Pagination

List endpoints support pagination:

```http
GET /api/v1/curricula?page=1&per_page=10
```

**Response Headers**
```
X-Total-Count: 25
X-Total-Pages: 3
X-Current-Page: 1
X-Per-Page: 10
```

## Testing

### Demo Credentials

Each tenant has demo users for testing:

**ACME Corporation** (`acme1.localhost:3000`)
- Admin: `admin_acme1` / `password`
- Demo: `demo_acme1` / `password`

**TechStart Inc** (`acme2.localhost:3000`)
- Admin: `admin_acme2` / `password`
- Demo: `demo_acme2` / `password`

**Global Solutions** (`acme3.localhost:3000`)
- Admin: `admin_acme3` / `password`
- Demo: `demo_acme3` / `password`

### Postman Collection

A complete Postman collection is available at `postman_collection.json` with all endpoints pre-configured for testing.

## SDKs and Libraries

### JavaScript/TypeScript
```javascript
// Example using fetch
const response = await fetch('https://acme1.curriculum-library-api.cerveras.com/api/v1/curricula', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const curricula = await response.json();
```

### Ruby
```ruby
require 'net/http'
require 'json'

uri = URI('https://acme1.curriculum-library-api.cerveras.com/api/v1/curricula')
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"
request['Content-Type'] = 'application/json'

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

curricula = JSON.parse(response.body)
```

## Support

For API support and questions:
- Documentation: [API Documentation](API_DOCUMENTATION.md)
- Testing: [Postman Collection](postman_collection.json)
- Implementation: [Multitenant Implementation](MULTITENANT_IMPLEMENTATION.md)
