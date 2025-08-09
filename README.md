# MDN Video Library API

A Rails API for managing video-based learning curricula, lessons, and user progress tracking.

## Features

- **Curriculum Management**: Create and manage learning paths with chapters and lessons
- **User Progress Tracking**: Monitor user completion of chapters and lessons
- **Notes & Highlights**: Users can take notes and highlight content
- **Authentication**: JWT-based authentication using Devise
- **API-First**: RESTful API designed for frontend consumption

## API Endpoints

### Authentication
- `POST /api/auth/sign_in` - User sign in
- `POST /api/auth/sign_up` - User registration
- `DELETE /api/auth/sign_out` - User sign out

### Curricula
- `GET /api/curricula` - List all curricula
- `GET /api/curricula/:id` - Get curriculum details with progress
- `POST /api/curricula/:id/enroll` - Enroll in a curriculum
- `GET /api/curricula/:id/enrollment_status` - Check enrollment status

### User Progress
- `GET /api/user/progress/:curriculum_id` - Get user progress for a curriculum
- `POST /api/user/progress/:curriculum_id/chapters/:chapter_id/complete` - Mark chapter as complete
- `POST /api/user/progress/:curriculum_id/lessons/:lesson_id/complete` - Mark lesson as complete

### Notes & Highlights
- `GET /api/user/notes/:curriculum_id` - Get user notes for a curriculum
- `POST /api/user/notes` - Create a new note
- `PUT /api/user/notes/:id` - Update a note
- `DELETE /api/user/notes/:id` - Delete a note

- `GET /api/user/highlights/:curriculum_id` - Get user highlights for a curriculum
- `POST /api/user/highlights` - Create a new highlight
- `PUT /api/user/highlights/:id` - Update a highlight
- `DELETE /api/user/highlights/:id` - Delete a highlight

## Quick Start

### Prerequisites
- Ruby 3.2.6
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
bin/rails server
```

The API will be available at `http://localhost:3000`

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

The application uses several key models:

- **User**: Authentication and user management
- **Curriculum**: Learning paths containing chapters
- **Chapter**: Sections within a curriculum containing lessons
- **Lesson**: Individual learning units
- **UserProgress**: Tracks user enrollment and chapter completion
- **LessonProgress**: Tracks individual lesson completion
- **UserNote**: User-generated notes for content
- **UserHighlight**: User highlights of content

### Key Relationships

- A User can enroll in multiple Curricula
- A Curriculum contains multiple Chapters
- A Chapter contains multiple Lessons
- UserProgress tracks enrollment and chapter completion
- LessonProgress tracks individual lesson completion
- Notes and Highlights are associated with specific chapters and curricula

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.
