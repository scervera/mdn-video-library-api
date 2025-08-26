# Bookmark API Documentation

This document outlines the complete bookmark functionality for the MDN Video Library API, including setup, endpoints, and usage examples.

## 🎯 Overview

The bookmark system allows users to create, manage, and retrieve bookmarks for specific video lessons. Each bookmark includes a title, notes, and timestamp, and is scoped to both the user and lesson for proper data isolation.

## 📋 Features

### 1. Database Schema
- **Bookmark Model**: `title` (string), `notes` (text), `timestamp` (decimal)
- **Associations**: Belongs to `User` and `Lesson`
- **Constraints**: Unique constraint on `[user_id, lesson_id, timestamp]`
- **Indexes**: Optimized for querying by user, lesson, and timestamp

### 2. API Endpoints
All endpoints require authentication via JWT token in the Authorization header.

#### V1 API Endpoints
- `GET /api/v1/lessons/:lesson_id/bookmarks` - Get all bookmarks for a lesson
- `GET /api/v1/lessons/:lesson_id/bookmarks/:id` - Get a specific bookmark
- `POST /api/v1/lessons/:lesson_id/bookmarks` - Create a new bookmark
- `PUT /api/v1/lessons/:lesson_id/bookmarks/:id` - Update a bookmark
- `DELETE /api/v1/lessons/:lesson_id/bookmarks/:id` - Delete a bookmark

#### Legacy API Endpoints
- `GET /api/lessons/:lesson_id/bookmarks` - Get all bookmarks for a lesson
- `GET /api/lessons/:lesson_id/bookmarks/:id` - Get a specific bookmark
- `POST /api/lessons/:lesson_id/bookmarks` - Create a new bookmark
- `PUT /api/lessons/:lesson_id/bookmarks/:id` - Update a bookmark
- `DELETE /api/lessons/:lesson_id/bookmarks/:id` - Delete a bookmark

## 🔧 Authentication

All bookmark endpoints require authentication. Include the JWT token in the Authorization header:

```bash
Authorization: Bearer YOUR_JWT_TOKEN
```

## 📊 API Examples

### 1. Get All Bookmarks for a Lesson

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/lessons/1/bookmarks
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "Important Point",
    "notes": "This is a key moment in the lesson",
    "timestamp": "120.5",
    "formatted_timestamp": "02:00",
    "formatted_timestamp_with_hours": "02:00",
    "lesson_id": 1,
    "user_id": 1,
    "created_at": "2025-08-16T18:03:30.912Z",
    "updated_at": "2025-08-16T18:03:30.912Z"
  }
]
```

### 2. Create a New Bookmark

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookmark": {
      "title": "Key Insight",
      "notes": "Important concept explained here",
      "timestamp": 180.0
    }
  }' \
  http://localhost:3000/api/v1/lessons/1/bookmarks
```

**Response:**
```json
{
  "id": 2,
  "title": "Key Insight",
  "notes": "Important concept explained here",
  "timestamp": "180.0",
  "formatted_timestamp": "03:00",
  "formatted_timestamp_with_hours": "03:00",
  "lesson_id": 1,
  "user_id": 1,
  "created_at": "2025-08-16T18:05:30.912Z",
  "updated_at": "2025-08-16T18:05:30.912Z"
}
```

### 3. Update a Bookmark

```bash
curl -X PUT \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookmark": {
      "title": "Updated Title",
      "notes": "Updated notes",
      "timestamp": 200.0
    }
  }' \
  http://localhost:3000/api/v1/lessons/1/bookmarks/2
```

### 4. Delete a Bookmark

```bash
curl -X DELETE \
  -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/lessons/1/bookmarks/2
```

**Response:**
```json
{
  "message": "Bookmark deleted successfully"
}
```

## 🔍 Request/Response Format

### Bookmark Object Structure

```json
{
  "id": 1,
  "title": "Bookmark Title",
  "notes": "Optional notes about the bookmark",
  "timestamp": "120.5",
  "formatted_timestamp": "02:00",
  "formatted_timestamp_with_hours": "02:00",
  "lesson_id": 1,
  "user_id": 1,
  "created_at": "2025-08-16T18:03:30.912Z",
  "updated_at": "2025-08-16T18:03:30.912Z"
}
```

### Create/Update Request Format

```json
{
  "bookmark": {
    "title": "Required: Bookmark title",
    "notes": "Optional: Notes about the bookmark",
    "timestamp": 120.5
  }
}
```

## ✅ Validations

### Required Fields
- **title**: Must be present and not blank (max 255 characters)
- **timestamp**: Must be present and greater than or equal to 0

### Unique Constraints
- Users cannot have multiple bookmarks at the same timestamp for the same lesson
- Error message: "User already has a bookmark at this timestamp for this lesson"

### Data Types
- **title**: String (required)
- **notes**: Text (optional)
- **timestamp**: Decimal (required, precision: 10, scale: 2)

## 🚨 Error Handling

### Common Error Responses

#### 1. Validation Errors (422 Unprocessable Entity)
```json
{
  "errors": [
    "Title can't be blank",
    "Timestamp must be greater than or equal to 0"
  ]
}
```

#### 2. Not Found Errors (404 Not Found)
```json
{
  "error": "Lesson not found"
}
```

```json
{
  "error": "Bookmark not found"
}
```

#### 3. Authentication Errors (401 Unauthorized)
```json
{
  "error": "No token provided"
}
```

```json
{
  "error": "Invalid token"
}
```

## 🎯 Frontend Integration

### React/Next.js Example

```jsx
import React, { useState, useEffect } from 'react';

const BookmarkManager = ({ lessonId, token }) => {
  const [bookmarks, setBookmarks] = useState([]);
  const [loading, setLoading] = useState(false);

  // Fetch bookmarks
  const fetchBookmarks = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/v1/lessons/${lessonId}/bookmarks`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      const data = await response.json();
      setBookmarks(data);
    } catch (error) {
      console.error('Error fetching bookmarks:', error);
    } finally {
      setLoading(false);
    }
  };

  // Create bookmark
  const createBookmark = async (bookmarkData) => {
    try {
      const response = await fetch(`/api/v1/lessons/${lessonId}/bookmarks`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ bookmark: bookmarkData })
      });
      
      if (response.ok) {
        const newBookmark = await response.json();
        setBookmarks([...bookmarks, newBookmark]);
      }
    } catch (error) {
      console.error('Error creating bookmark:', error);
    }
  };

  // Delete bookmark
  const deleteBookmark = async (bookmarkId) => {
    try {
      const response = await fetch(`/api/v1/lessons/${lessonId}/bookmarks/${bookmarkId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        setBookmarks(bookmarks.filter(b => b.id !== bookmarkId));
      }
    } catch (error) {
      console.error('Error deleting bookmark:', error);
    }
  };

  useEffect(() => {
    fetchBookmarks();
  }, [lessonId]);

  return (
    <div className="bookmark-manager">
      <h3>Bookmarks</h3>
      {loading ? (
        <p>Loading bookmarks...</p>
      ) : (
        <div className="bookmarks-list">
          {bookmarks.map(bookmark => (
            <div key={bookmark.id} className="bookmark-item">
              <h4>{bookmark.title}</h4>
              <p>{bookmark.notes}</p>
              <span className="timestamp">{bookmark.formatted_timestamp}</span>
              <button onClick={() => deleteBookmark(bookmark.id)}>
                Delete
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
```

### Vanilla JavaScript Example

```javascript
class BookmarkAPI {
  constructor(baseURL, token) {
    this.baseURL = baseURL;
    this.token = token;
  }

  async getBookmarks(lessonId) {
    const response = await fetch(`${this.baseURL}/api/v1/lessons/${lessonId}/bookmarks`, {
      headers: {
        'Authorization': `Bearer ${this.token}`
      }
    });
    return response.json();
  }

  async createBookmark(lessonId, bookmarkData) {
    const response = await fetch(`${this.baseURL}/api/v1/lessons/${lessonId}/bookmarks`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ bookmark: bookmarkData })
    });
    return response.json();
  }

  async updateBookmark(lessonId, bookmarkId, bookmarkData) {
    const response = await fetch(`${this.baseURL}/api/v1/lessons/${lessonId}/bookmarks/${bookmarkId}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ bookmark: bookmarkData })
    });
    return response.json();
  }

  async deleteBookmark(lessonId, bookmarkId) {
    const response = await fetch(`${this.baseURL}/api/v1/lessons/${lessonId}/bookmarks/${bookmarkId}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${this.token}`
      }
    });
    return response.json();
  }
}

// Usage
const bookmarkAPI = new BookmarkAPI('http://localhost:3000', 'your-jwt-token');

// Get bookmarks
bookmarkAPI.getBookmarks(1).then(bookmarks => {
  console.log('Bookmarks:', bookmarks);
});

// Create bookmark
bookmarkAPI.createBookmark(1, {
  title: 'Important Point',
  notes: 'Key concept explained',
  timestamp: 120.5
}).then(bookmark => {
  console.log('Created bookmark:', bookmark);
});
```

## 🔒 Security Features

### 1. User Scoping
- All bookmarks are automatically scoped to the authenticated user
- Users can only access their own bookmarks
- No cross-user data leakage possible

### 2. Authentication Required
- All endpoints require valid JWT authentication
- Unauthenticated requests return 401 Unauthorized

### 3. Data Validation
- Server-side validation of all input data
- SQL injection protection through ActiveRecord
- XSS protection through proper JSON encoding

## 📈 Performance Considerations

### 1. Database Indexes
- Index on `[user_id, lesson_id]` for fast user/lesson queries
- Index on `[lesson_id, timestamp]` for chronological ordering
- Unique index on `[user_id, lesson_id, timestamp]` for constraint enforcement

### 2. Query Optimization
- Bookmarks are ordered by timestamp for consistent display
- Efficient scoping prevents unnecessary data retrieval
- Proper eager loading when needed

## 🚀 Deployment Notes

### 1. Database Migration
The bookmark functionality includes a database migration that:
- Creates the `bookmarks` table
- Adds proper constraints and indexes
- Ensures data integrity

### 2. Environment Setup
No additional environment variables are required beyond the existing authentication setup.

### 3. Backward Compatibility
Both v1 and legacy API endpoints are supported for seamless integration.

## 🎉 Success!

The bookmark functionality is now fully implemented and ready for production use! The API provides:

- ✅ Complete CRUD operations for bookmarks
- ✅ Proper authentication and authorization
- ✅ Comprehensive validation and error handling
- ✅ Optimized database queries and indexes
- ✅ Both v1 and legacy API support
- ✅ Formatted timestamp display
- ✅ Unique constraint enforcement
- ✅ User-scoped data isolation

Your frontend can now integrate with these endpoints to provide a complete bookmark experience for your video lessons!
