# Frontend Curriculum CRUD Implementation Guide

## ✅ **Backend Status: FULL CRUD OPERATIONS READY**

The backend now provides **complete CRUD operations** for curriculum management with proper authorization and tenant isolation. All endpoints are deployed and ready for frontend integration.

## 🔐 **Authentication & Authorization**

### **Required Headers**
```javascript
const headers = {
  'Authorization': `Bearer ${jwtToken}`,
  'X-Tenant': tenantSlug,
  'Content-Type': 'application/json'
}
```

### **Authorization Levels**
- **Admin Users**: Full CRUD access to all curriculum operations
- **Regular Users**: Read-only access to published content + progress tracking
- **Unauthenticated**: No access (except health checks)

## 📚 **Curriculum Management Endpoints**

### **1. Curriculum CRUD Operations**

#### **List Curricula**
```javascript
// GET /api/v1/curricula
const response = await fetch('https://curriculum-library-api.cerveras.com/api/v1/curricula', {
  headers
})
const curricula = await response.json()
```

**Response Structure:**
```json
[
  {
    "id": 1,
    "title": "JavaScript Fundamentals",
    "description": "Learn the basics of JavaScript programming",
    "order_index": 1,
    "published": true,
    "total_chapters": 5,
    "total_lessons": 15,
    "completed_chapters": 2,
    "completed_lessons": 8,
    "enrolled": true,
    "chapters": [...]
  }
]
```

#### **Get Single Curriculum**
```javascript
// GET /api/v1/curricula/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}`, {
  headers
})
const curriculum = await response.json()
```

#### **Create Curriculum (Admin Only)**
```javascript
// POST /api/v1/curricula
const response = await fetch('https://curriculum-library-api.cerveras.com/api/v1/curricula', {
  method: 'POST',
  headers,
  body: JSON.stringify({
    curriculum: {
      title: "New Curriculum",
      description: "Curriculum description",
      order_index: 1,
      published: false
    }
  })
})
```

#### **Update Curriculum (Admin Only)**
```javascript
// PUT /api/v1/curricula/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}`, {
  method: 'PUT',
  headers,
  body: JSON.stringify({
    curriculum: {
      title: "Updated Title",
      description: "Updated description",
      published: true
    }
  })
})
```

#### **Delete Curriculum (Admin Only)**
```javascript
// DELETE /api/v1/curricula/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}`, {
  method: 'DELETE',
  headers
})
```

### **2. Chapter CRUD Operations**

#### **List Chapters**
```javascript
// GET /api/v1/curricula/{curriculum_id}/chapters
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters`, {
  headers
})
```

#### **Create Chapter (Admin Only)**
```javascript
// POST /api/v1/curricula/{curriculum_id}/chapters
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters`, {
  method: 'POST',
  headers,
  body: JSON.stringify({
    chapter: {
      title: "New Chapter",
      description: "Chapter description",
      duration: "30 minutes",
      order_index: 1,
      published: false
    }
  })
})
```

#### **Update Chapter (Admin Only)**
```javascript
// PUT /api/v1/curricula/{curriculum_id}/chapters/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}`, {
  method: 'PUT',
  headers,
  body: JSON.stringify({
    chapter: {
      title: "Updated Chapter Title",
      published: true
    }
  })
})
```

#### **Delete Chapter (Admin Only)**
```javascript
// DELETE /api/v1/curricula/{curriculum_id}/chapters/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}`, {
  method: 'DELETE',
  headers
})
```

### **3. Lesson CRUD Operations**

#### **List Lessons**
```javascript
// GET /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/lessons`, {
  headers
})
```

#### **Create Lesson (Admin Only)**
```javascript
// POST /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/lessons`, {
  method: 'POST',
  headers,
  body: JSON.stringify({
    lesson: {
      title: "New Lesson",
      description: "Lesson description",
      content_type: "video",
      content: "Lesson content",
      order_index: 1,
      published: false,
      cloudflare_stream_id: "optional_stream_id"
    }
  })
})
```

#### **Update Lesson (Admin Only)**
```javascript
// PUT /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/lessons/${lessonId}`, {
  method: 'PUT',
  headers,
  body: JSON.stringify({
    lesson: {
      title: "Updated Lesson Title",
      content: "Updated content",
      published: true
    }
  })
})
```

#### **Delete Lesson (Admin Only)**
```javascript
// DELETE /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons/{id}
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/lessons/${lessonId}`, {
  method: 'DELETE',
  headers
})
```

## 🎯 **Progress Tracking Endpoints**

### **Enroll in Curriculum**
```javascript
// POST /api/v1/curricula/{id}/enroll
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/enroll`, {
  method: 'POST',
  headers
})
```

### **Check Enrollment Status**
```javascript
// GET /api/v1/curricula/{id}/enrollment_status
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/enrollment_status`, {
  headers
})
```

### **Complete Chapter**
```javascript
// POST /api/v1/curricula/{curriculum_id}/chapters/{id}/complete
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/complete`, {
  method: 'POST',
  headers
})
```

### **Complete Lesson**
```javascript
// POST /api/v1/curricula/{curriculum_id}/chapters/{chapter_id}/lessons/{id}/complete
const response = await fetch(`https://curriculum-library-api.cerveras.com/api/v1/curricula/${curriculumId}/chapters/${chapterId}/lessons/${lessonId}/complete`, {
  method: 'POST',
  headers
})
```

## 📊 **Data Models & Structures**

### **Curriculum Object**
```typescript
interface Curriculum {
  id: number
  title: string
  description: string
  order_index: number
  published: boolean
  total_chapters: number
  total_lessons: number
  completed_chapters: number
  completed_lessons: number
  enrolled: boolean
  chapters: Chapter[]
}
```

### **Chapter Object**
```typescript
interface Chapter {
  id: number
  title: string
  description: string
  duration: string
  order_index: number
  published: boolean
  lessons: Lesson[]
  isLocked: boolean
  completed: boolean
  completed_at: string | null
  total_lessons: number
  completed_lessons: number
}
```

### **Lesson Object**
```typescript
interface Lesson {
  id: number
  title: string
  description: string
  content_type: 'video' | 'text' | 'image' | 'pdf'
  content: string
  media_url: string
  order_index: number
  published: boolean
  chapter_id: number
  completed: boolean
  completed_at: string | null
  cloudflare_stream_id: string
  cloudflare_stream_thumbnail: string
  cloudflare_stream_duration: number
  cloudflare_stream_status: string
  formatted_duration: string
  video_ready: boolean
  video_player_data: VideoPlayerData
}

interface VideoPlayerData {
  cloudflare_stream_id: string
  player_url: string
  thumbnail_url: string
  duration: number
  formatted_duration: string
  status: string
  ready: boolean
  preview_url: string
  download_url: string
}
```

## 🔧 **Frontend Implementation Examples**

### **API Client Setup**
```javascript
class CurriculumAPI {
  constructor(baseURL, token, tenantSlug) {
    this.baseURL = baseURL
    this.headers = {
      'Authorization': `Bearer ${token}`,
      'X-Tenant': tenantSlug,
      'Content-Type': 'application/json'
    }
  }

  async getCurricula() {
    const response = await fetch(`${this.baseURL}/api/v1/curricula`, {
      headers: this.headers
    })
    return response.json()
  }

  async createCurriculum(curriculumData) {
    const response = await fetch(`${this.baseURL}/api/v1/curricula`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ curriculum: curriculumData })
    })
    return response.json()
  }

  async updateCurriculum(id, curriculumData) {
    const response = await fetch(`${this.baseURL}/api/v1/curricula/${id}`, {
      method: 'PUT',
      headers: this.headers,
      body: JSON.stringify({ curriculum: curriculumData })
    })
    return response.json()
  }

  async deleteCurriculum(id) {
    const response = await fetch(`${this.baseURL}/api/v1/curricula/${id}`, {
      method: 'DELETE',
      headers: this.headers
    })
    return response.json()
  }
}
```

### **React Hook Example**
```javascript
import { useState, useEffect } from 'react'

export function useCurricula() {
  const [curricula, setCurricula] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchCurricula = async () => {
    try {
      setLoading(true)
      const response = await curriculumAPI.getCurricula()
      setCurricula(response)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const createCurriculum = async (curriculumData) => {
    try {
      const newCurriculum = await curriculumAPI.createCurriculum(curriculumData)
      setCurricula(prev => [...prev, newCurriculum])
      return newCurriculum
    } catch (err) {
      setError(err.message)
      throw err
    }
  }

  useEffect(() => {
    fetchCurricula()
  }, [])

  return { curricula, loading, error, createCurriculum, fetchCurricula }
}
```

## 🚨 **Error Handling**

### **Common Error Responses**
```javascript
// 401 Unauthorized
{
  "error": "You need to sign in or sign up before continuing."
}

// 403 Forbidden (Admin required)
{
  "error": "Admin access required"
}

// 422 Unprocessable Entity
{
  "errors": ["Title can't be blank", "Order index has already been taken"]
}

// 404 Not Found
{
  "error": "Couldn't find Curriculum with 'id'=999"
}
```

### **Error Handling Example**
```javascript
async function handleCurriculumOperation(operation) {
  try {
    const result = await operation()
    return { success: true, data: result }
  } catch (error) {
    if (error.status === 401) {
      // Redirect to login
      router.push('/login')
    } else if (error.status === 403) {
      // Show admin required message
      showNotification('Admin access required', 'error')
    } else if (error.status === 422) {
      // Show validation errors
      const errors = await error.json()
      showValidationErrors(errors.errors)
    } else {
      // Show generic error
      showNotification('An error occurred', 'error')
    }
    return { success: false, error }
  }
}
```

## 📋 **Implementation Checklist**

### **Phase 1: Basic CRUD Operations**
- [ ] **Curriculum Management**
  - [ ] List curricula (read-only for users)
  - [ ] View single curriculum with chapters/lessons
  - [ ] Create curriculum (admin only)
  - [ ] Update curriculum (admin only)
  - [ ] Delete curriculum (admin only)

- [ ] **Chapter Management**
  - [ ] List chapters within curriculum
  - [ ] Create chapter (admin only)
  - [ ] Update chapter (admin only)
  - [ ] Delete chapter (admin only)

- [ ] **Lesson Management**
  - [ ] List lessons within chapter
  - [ ] Create lesson (admin only)
  - [ ] Update lesson (admin only)
  - [ ] Delete lesson (admin only)

### **Phase 2: Progress Tracking**
- [ ] **User Progress**
  - [ ] Enroll in curriculum
  - [ ] Check enrollment status
  - [ ] Mark chapter as complete
  - [ ] Mark lesson as complete
  - [ ] Display progress indicators

### **Phase 3: Advanced Features**
- [ ] **Content Management**
  - [ ] Video upload/Cloudflare Stream integration
  - [ ] Content type handling (video, text, image, pdf)
  - [ ] Publish/unpublish content
  - [ ] Order management (drag & drop)

- [ ] **User Experience**
  - [ ] Progress visualization
  - [ ] Locked/unlocked chapter states
  - [ ] Completion tracking
  - [ ] Admin vs user views

## 🎯 **Success Criteria**

### **Admin Users Can:**
- ✅ Create, read, update, delete curricula
- ✅ Create, read, update, delete chapters
- ✅ Create, read, update, delete lessons
- ✅ Manage content publishing status
- ✅ Reorder curriculum items
- ✅ Upload and manage video content

### **Regular Users Can:**
- ✅ View published curricula
- ✅ Enroll in curricula
- ✅ Track progress through chapters/lessons
- ✅ Mark content as complete
- ✅ View their learning progress

### **System Features:**
- ✅ Proper authorization (admin vs user)
- ✅ Tenant isolation (multi-tenant support)
- ✅ Progress tracking and persistence
- ✅ Content publishing workflow
- ✅ Video streaming integration

---

**Status**: ✅ **READY** - All CRUD endpoints implemented and deployed  
**Authorization**: ✅ **SECURE** - Admin-only write operations  
**Tenant Isolation**: ✅ **ENFORCED** - All data scoped to tenant  
**Progress Tracking**: ✅ **FUNCTIONAL** - Complete user progress system  
**Video Integration**: ✅ **SUPPORTED** - Cloudflare Stream integration ready
