# Lesson Modules API - Quick Reference

## Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/v1/lessons/:lesson_id/lesson_modules` | List all modules | Yes |
| GET | `/api/v1/lessons/:lesson_id/lesson_modules/:id` | Get single module | Yes |
| POST | `/api/v1/lessons/:lesson_id/lesson_modules` | Create module | Admin |
| PATCH | `/api/v1/lessons/:lesson_id/lesson_modules/:id` | Update module | Admin |
| DELETE | `/api/v1/lessons/:lesson_id/lesson_modules/:id` | Delete module | Admin |
| PATCH | `/api/v1/lessons/:lesson_id/lesson_modules/reorder` | Reorder modules | Admin |
| GET | `/api/v1/lessons/:id?include_modules=true` | Get lesson with modules | Yes |

## Module Types

| Type | Description | Key Fields |
|------|-------------|------------|
| `TextModule` | Rich text content | `content`, `word_count`, `reading_time` |
| `VideoModule` | Cloudflare Stream video | `cloudflare_stream_id`, `video_player_data` |
| `AssessmentModule` | Interactive quiz | `questions`, `passing_score`, `total_points` |
| `ResourcesModule` | Files and links | `resources`, `resource_count`, `total_file_size` |
| `ImageModule` | Image gallery | `images`, `layout`, `image_count` |

## Common Fields

All modules have these base fields:
- `id`, `type`, `title`, `description`
- `position`, `settings`, `published`
- `published_at`, `created_at`, `updated_at`

## Example Requests

### Create Text Module
```bash
POST /api/v1/lessons/1/lesson_modules
{
  "lesson_module": {
    "type": "TextModule",
    "title": "Introduction",
    "content": "<h1>Welcome!</h1><p>Content...</p>"
  }
}
```

### Create Video Module
```bash
POST /api/v1/lessons/1/lesson_modules
{
  "lesson_module": {
    "type": "VideoModule",
    "title": "Tutorial Video",
    "cloudflare_stream_id": "12345678901234567890123456789012"
  }
}
```

### Create Assessment Module
```bash
POST /api/v1/lessons/1/lesson_modules
{
  "lesson_module": {
    "type": "AssessmentModule",
    "title": "Quiz",
    "settings": {
      "questions": [
        {
          "text": "What is 2+2?",
          "type": "single_choice",
          "options": ["3", "4", "5"],
          "correct_answer": 1,
          "points": 1
        }
      ],
      "passing_score": 70
    }
  }
}
```

### Reorder Modules
```bash
PATCH /api/v1/lessons/1/lesson_modules/reorder
{
  "module_ids": [3, 1, 2]
}
```

## Error Codes

| Status | Description |
|--------|-------------|
| 401 | Authentication required |
| 403 | Admin access required |
| 422 | Validation errors |
| 404 | Module not found |

## Authentication

Include JWT token in Authorization header:
```
Authorization: Bearer <jwt_token>
```
