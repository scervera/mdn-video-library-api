# Christian Curriculum API

A Ruby on Rails API backend for a Christian curriculum application built with Next.js frontend.

## Features

- **Authentication**: JWT-based authentication using Devise
- **Curriculum Management**: Chapters and lessons with progress tracking
- **User Progress**: Track completion of chapters and lessons
- **User Notes**: Allow users to take notes on chapters
- **User Highlights**: Allow users to highlight important text
- **RESTful API**: Clean, RESTful API design
- **CORS Support**: Configured for cross-origin requests

## Prerequisites

- Ruby 3.2.6+
- Rails 7.1+
- PostgreSQL
- Redis (for session storage)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mdn-video-library-api
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## Database Configuration

The application is configured to use PostgreSQL with the following default settings:
- Database: `mdn_video_library_api_development`
- Username: Default PostgreSQL user
- Password: None (local development)

To use custom database credentials, update `config/database.yml`:
```yaml
development:
  username: your_username
  password: your_password
```

## API Endpoints

### Authentication

#### POST /api/auth/login
Login with username and password.

**Request:**
```json
{
  "username": "user123",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "username": "user123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe",
    "active": true
  },
  "token": "jwt_token_here"
}
```

#### POST /api/auth/register
Register a new user.

**Request:**
```json
{
  "user": {
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "Jane",
    "last_name": "Smith"
  }
}
```

#### POST /api/auth/logout
Logout (token invalidation).

#### GET /api/auth/me
Get current user information.

### Chapters

#### GET /api/chapters
Get all published chapters with progress information.

**Response:**
```json
[
  {
    "id": 1,
    "title": "Foundation of Faith",
    "description": "Understanding the core principles...",
    "duration": "2 hours",
    "order_index": 1,
    "published": true,
    "lessons": [...],
    "isLocked": false,
    "completed": true,
    "completed_at": "2024-01-01T10:00:00Z",
    "total_lessons": 3,
    "completed_lessons": 2
  }
]
```

#### GET /api/chapters/:id
Get a specific chapter with progress information.

#### POST /api/chapters/:id/complete
Mark a chapter as completed.

### Lessons

#### GET /api/chapters/:chapter_id/lessons
Get all lessons for a specific chapter.

#### GET /api/lessons/:id
Get a specific lesson with progress information.

#### POST /api/lessons/:id/complete
Mark a lesson as completed.

### User Progress

#### GET /api/user/progress
Get user's overall progress.

**Response:**
```json
{
  "completedChapters": [1, 2, 3],
  "completedLessons": [1, 2, 3, 4, 5],
  "notes": {
    "1": "My notes for chapter 1",
    "2": "Important points from chapter 2"
  },
  "highlights": {
    "1": ["Important text 1", "Important text 2"],
    "2": ["Key concept"]
  }
}
```

### User Notes

#### GET /api/user/notes
Get all user notes.

#### GET /api/user/notes/:id
Get a specific note.

#### POST /api/user/notes
Create a new note.

**Request:**
```json
{
  "note": {
    "chapter_id": 1,
    "content": "My notes for this chapter"
  }
}
```

#### PUT /api/user/notes/:id
Update a note.

#### DELETE /api/user/notes/:id
Delete a note.

### User Highlights

#### GET /api/user/highlights
Get all user highlights.

#### GET /api/user/highlights/:id
Get a specific highlight.

#### POST /api/user/highlights
Create a new highlight.

**Request:**
```json
{
  "highlight": {
    "chapter_id": 1,
    "highlighted_text": "Important text to highlight"
  }
}
```

#### PUT /api/user/highlights/:id
Update a highlight.

#### DELETE /api/user/highlights/:id
Delete a highlight.

## Authentication

All API endpoints (except authentication endpoints) require a valid JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Sample Data

The application comes with sample data including:

- 5 sample users with credentials `password123`
- 5 chapters with 18 total lessons
- Sample user progress, notes, and highlights

### Sample Users

1. `edra_stokes` - Denver Stamm
2. `silas` - Lavon Beer
3. `jarred_stamm` - Amada Rau
4. `clair` - Freddie Rau
5. `don.quigley` - Violet Hudson

All users have the password: `password123`

## Models

### User
- Authentication using Devise
- Username, email, first_name, last_name
- Associations with progress, notes, and highlights

### Chapter
- Title, description, duration, order_index
- Published status
- Has many lessons and user progress

### Lesson
- Title, description, content_type, content
- Order index within chapter
- Published status
- Belongs to chapter

### UserProgress
- Tracks chapter completion
- Completed status and timestamp

### LessonProgress
- Tracks lesson completion
- Completed status and timestamp

### UserNote
- User notes for chapters
- Content and chapter association

### UserHighlight
- User highlights for chapters
- Highlighted text and chapter association

## Development

### Running Tests
```bash
rails test
```

### Console
```bash
rails console
```

### Database Reset
```bash
rails db:reset
```

## Environment Variables

Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL=postgresql://localhost/mdn_video_library_api_development

# JWT Secret
JWT_SECRET_KEY=your-secret-key-here

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

## CORS Configuration

The API is configured to accept requests from:
- `http://localhost:3000` (Next.js development)
- `http://localhost:3001` (alternative port)
- Any origins specified in `ALLOWED_ORIGINS` environment variable

## License

This project is licensed under the MIT License.
