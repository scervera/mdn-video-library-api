# Lesson Modules API Documentation

## Overview

The Lesson Modules system provides a flexible, modular approach to creating rich educational content. Each lesson can contain multiple modules of different types, allowing for diverse learning experiences.

## Module Types

### 1. TextModule
Rich text content with Tiptap editor integration.

**Features:**
- HTML content support
- Word count and reading time calculation
- Table of contents generation
- Excerpt generation

### 2. VideoModule
Video content with Cloudflare Stream integration.

**Features:**
- Cloudflare Stream video embedding
- Video player data and controls
- Duration and status tracking
- Thumbnail and preview URLs

### 3. AssessmentModule
Interactive quizzes and assessments.

**Features:**
- Multiple question types (single choice, multiple choice, true/false)
- Scoring and passing thresholds
- Time limits and retake settings
- Question randomization

### 4. ResourcesModule
Downloadable files, links, and additional resources.

**Features:**
- File downloads with size tracking
- External links
- Resource categorization
- Total file size calculation

### 5. ImageModule
Image galleries and visual content.

**Features:**
- Single images, galleries, carousels, grids
- Image captions and alt text
- Thumbnail support
- Layout customization

## API Endpoints

### Base URL
All endpoints are prefixed with `/api/v1/lessons/:lesson_id/lesson_modules`

### Authentication
All endpoints require JWT authentication in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### 1. List Lesson Modules
**GET** `/api/v1/lessons/:lesson_id/lesson_modules`

Returns all modules for a lesson, ordered by position.

**Response:**
```json
[
  {
    "id": 1,
    "type": "TextModule",
    "title": "Introduction",
    "description": "Welcome to this lesson",
    "position": 1,
    "settings": {},
    "published": true,
    "published_at": "2025-08-26T19:33:08.667Z",
    "created_at": "2025-08-26T19:33:08.667Z",
    "updated_at": "2025-08-26T19:33:08.667Z",
    "content": "<h1>Welcome!</h1><p>This is the content...</p>",
    "word_count": 15,
    "reading_time": 1,
    "table_of_contents": [...],
    "excerpt": "Welcome! This is the content..."
  }
]
```

### 2. Get Single Module
**GET** `/api/v1/lessons/:lesson_id/lesson_modules/:id`

Returns a specific module with type-specific data.

**Response:** Same as above, but for a single module.

### 3. Create Module
**POST** `/api/v1/lessons/:lesson_id/lesson_modules`

Creates a new module. Requires admin access.

**Request Body Examples:**

#### TextModule
```json
{
  "lesson_module": {
    "type": "TextModule",
    "title": "Introduction to HTML",
    "description": "Learn HTML basics",
    "content": "<h1>What is HTML?</h1><p>HTML is...</p>"
  }
}
```

#### VideoModule
```json
{
  "lesson_module": {
    "type": "VideoModule",
    "title": "HTML Tutorial Video",
    "description": "Watch this video",
    "cloudflare_stream_id": "12345678901234567890123456789012"
  }
}
```

#### AssessmentModule
```json
{
  "lesson_module": {
    "type": "AssessmentModule",
    "title": "HTML Quiz",
    "description": "Test your knowledge",
    "settings": {
      "questions": [
        {
          "text": "What does HTML stand for?",
          "type": "single_choice",
          "options": ["HyperText Markup Language", "High Tech Modern Language"],
          "correct_answer": 0,
          "points": 1
        }
      ],
      "passing_score": 70,
      "time_limit": 10
    }
  }
}
```

#### ResourcesModule
```json
{
  "lesson_module": {
    "type": "ResourcesModule",
    "title": "Additional Resources",
    "description": "Download helpful files",
    "settings": {
      "resources": [
        {
          "title": "HTML Cheat Sheet",
          "type": "file",
          "url": "https://example.com/cheat-sheet.pdf",
          "file_size": 1024000
        },
        {
          "title": "MDN Documentation",
          "type": "link",
          "url": "https://developer.mozilla.org/en-US/docs/Web/HTML"
        }
      ]
    }
  }
}
```

#### ImageModule
```json
{
  "lesson_module": {
    "type": "ImageModule",
    "title": "HTML Examples",
    "description": "Visual examples",
    "settings": {
      "images": [
        {
          "title": "HTML Structure",
          "url": "https://example.com/structure.png",
          "alt_text": "HTML document structure diagram",
          "thumbnail_url": "https://example.com/structure-thumb.png"
        }
      ],
      "layout": "single"
    }
  }
}
```

### 4. Update Module
**PATCH** `/api/v1/lessons/:lesson_id/lesson_modules/:id`

Updates an existing module. Requires admin access.

**Request Body:** Same format as create, but only include fields to update.

### 5. Delete Module
**DELETE** `/api/v1/lessons/:lesson_id/lesson_modules/:id`

Deletes a module. Requires admin access.

**Response:**
```json
{
  "message": "Module deleted successfully"
}
```

### 6. Reorder Modules
**PATCH** `/api/v1/lessons/:lesson_id/lesson_modules/reorder`

Reorders modules within a lesson. Requires admin access.

**Request Body:**
```json
{
  "module_ids": [3, 1, 2]
}
```

**Response:**
```json
{
  "message": "Modules reordered successfully"
}
```

## Type-Specific Response Data

### TextModule
```json
{
  "content": "<h1>Title</h1><p>Content...</p>",
  "word_count": 25,
  "reading_time": 2,
  "table_of_contents": [
    {
      "id": "heading-1",
      "level": 1,
      "text": "Title",
      "index": 1
    }
  ],
  "excerpt": "Title Content..."
}
```

### VideoModule
```json
{
  "cloudflare_stream_id": "12345678901234567890123456789012",
  "cloudflare_stream_thumbnail": "https://...",
  "cloudflare_stream_duration": 180,
  "cloudflare_stream_status": "ready",
  "formatted_duration": "3:00",
  "video_ready": true,
  "video_player_data": {
    "cloudflare_stream_id": "...",
    "player_url": "https://...",
    "thumbnail_url": "https://...",
    "duration": 180,
    "formatted_duration": "3:00",
    "status": "ready",
    "ready": true,
    "preview_url": "https://...",
    "download_url": "https://..."
  }
}
```

### AssessmentModule
```json
{
  "questions": [
    {
      "text": "Question text",
      "type": "single_choice",
      "options": ["Option 1", "Option 2"],
      "correct_answer": 0,
      "points": 1
    }
  ],
  "question_count": 1,
  "total_points": 1,
  "passing_score": 70,
  "estimated_time": 2
}
```

### ResourcesModule
```json
{
  "resources": [
    {
      "title": "File Name",
      "type": "file",
      "url": "https://...",
      "file_size": 1024000
    }
  ],
  "resource_count": 1,
  "file_resources": [...],
  "link_resources": [...],
  "total_file_size": 1024000,
  "formatted_total_size": "1000.0 KB"
}
```

### ImageModule
```json
{
  "images": [
    {
      "title": "Image Title",
      "url": "https://...",
      "alt_text": "Description",
      "thumbnail_url": "https://..."
    }
  ],
  "image_count": 1,
  "layout": "single",
  "single_image": true,
  "gallery": false,
  "carousel": false,
  "grid": false
}
```

## Error Responses

### Validation Errors
```json
{
  "errors": [
    "Title can't be blank",
    "Type is not included in the list"
  ]
}
```

### Authentication Error
```json
{
  "error": "No token provided"
}
```

### Authorization Error
```json
{
  "error": "Admin access required"
}
```

### Not Found Error
```json
{
  "error": "Couldn't find LessonModule with id=123"
}
```

## Updated Lesson Endpoints

### Get Lesson with Modules
**GET** `/api/v1/lessons/:id?include_modules=true`

Returns lesson data with all modules included.

**Response:**
```json
{
  "id": 1,
  "title": "Lesson Title",
  "description": "Lesson description",
  "order_index": 1,
  "published": true,
  "chapter_id": 1,
  "completed": false,
  "completed_at": null,
  "module_count": 3,
  "has_video_modules": true,
  "has_text_modules": true,
  "has_assessment_modules": false,
  "modules": [
    // Array of module objects as shown above
  ]
}
```

## Best Practices

1. **Module Ordering**: Always use the position field for display order
2. **Type Validation**: Validate module types on the frontend before sending
3. **Settings Handling**: Use the settings field for module-specific configuration
4. **Error Handling**: Always handle validation and authorization errors
5. **Content Loading**: Use the include_modules parameter to load lesson content efficiently

## Rate Limits

- Standard API rate limits apply
- Reorder operations are limited to prevent abuse
- File uploads (for resources) have size limits

## Support

For questions or issues with the Lesson Modules API, please refer to the backend team or create an issue in the project repository.
