# Postman API Testing Guide

This guide shows you how to test your Rails 8 API using Postman.

## 🚀 Setup

### Base URL
```
http://cloud.cerveras.com
```

### Import Postman Collection
You can import this collection into Postman or create requests manually.

## 🔐 Authentication

Your API uses JWT (JSON Web Token) authentication. You'll need to:

1. **Login** to get a token
2. **Include the token** in subsequent requests

### Authentication Flow
1. Register a new user OR login with existing credentials
2. Copy the `token` from the response
3. Add the token to the `Authorization` header for protected endpoints

## 📝 API Endpoints

### 1. Authentication Endpoints

#### Register a New User
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### Get Current User
```
GET /api/auth/me
Authorization: Bearer <your_token>
```

#### Logout
```
POST /api/auth/logout
Authorization: Bearer <your_token>
```

### 2. Curricula Endpoints

#### Get All Curricula
```
GET /api/curricula
Authorization: Bearer <your_token>
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "Christian Foundation",
    "description": "Basic Christian principles and faith foundation",
    "chapters": [
      {
        "id": 1,
        "title": "Foundation of Faith",
        "lessons": [
          {
            "id": 1,
            "title": "Introduction to Faith",
            "content": "Understanding the basics of Christian faith..."
          }
        ]
      }
    ]
  }
]
```

#### Get Single Curriculum
```
GET /api/curricula/1
Authorization: Bearer <your_token>
```

#### Enroll in Curriculum
```
POST /api/curricula/1/enroll
Authorization: Bearer <your_token>
```

#### Check Enrollment Status
```
GET /api/curricula/1/enrollment_status
Authorization: Bearer <your_token>
```

### 3. Chapters Endpoints

#### Get Chapters for Curriculum
```
GET /api/curricula/1/chapters
Authorization: Bearer <your_token>
```

#### Get Single Chapter
```
GET /api/chapters/1
Authorization: Bearer <your_token>
```

#### Complete Chapter
```
POST /api/chapters/1/complete
Authorization: Bearer <your_token>
```

### 4. Lessons Endpoints

#### Get Lessons for Chapter
```
GET /api/chapters/1/lessons
Authorization: Bearer <your_token>
```

#### Get Single Lesson
```
GET /api/lessons/1
Authorization: Bearer <your_token>
```

#### Complete Lesson
```
POST /api/lessons/1/complete
Authorization: Bearer <your_token>
```

### 5. User Progress Endpoints

#### Get User Progress
```
GET /api/user/progress
Authorization: Bearer <your_token>
```

#### Get Curriculum Progress
```
GET /api/user/progress/1
Authorization: Bearer <your_token>
```

### 6. User Notes Endpoints

#### Get All Notes
```
GET /api/user/notes
Authorization: Bearer <your_token>
```

#### Get Single Note
```
GET /api/user/notes/1
Authorization: Bearer <your_token>
```

#### Create Note
```
POST /api/user/notes
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "lesson_id": 1,
  "content": "This is my note about the lesson",
  "position": 0
}
```

#### Update Note
```
PUT /api/user/notes/1
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "content": "Updated note content"
}
```

#### Delete Note
```
DELETE /api/user/notes/1
Authorization: Bearer <your_token>
```

### 7. User Highlights Endpoints

#### Get All Highlights
```
GET /api/user/highlights
Authorization: Bearer <your_token>
```

#### Get Single Highlight
```
GET /api/user/highlights/1
Authorization: Bearer <your_token>
```

#### Create Highlight
```
POST /api/user/highlights
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "lesson_id": 1,
  "content": "Highlighted text from lesson",
  "start_position": 0,
  "end_position": 50
}
```

#### Update Highlight
```
PUT /api/user/highlights/1
Authorization: Bearer <your_token>
Content-Type: application/json

{
  "content": "Updated highlight content"
}
```

#### Delete Highlight
```
DELETE /api/user/highlights/1
Authorization: Bearer <your_token>
```

## 🛠️ Postman Setup

### 1. Create Environment Variables

In Postman, create an environment with these variables:

| Variable | Initial Value | Current Value |
|----------|---------------|---------------|
| `base_url` | `http://cloud.cerveras.com` | `http://cloud.cerveras.com` |
| `token` | (leave empty) | (will be set after login) |

### 2. Set Up Authorization

For protected endpoints, use:
- **Type**: Bearer Token
- **Token**: `{{token}}`

### 3. Create Request Headers

Set these headers for all requests:
```
Content-Type: application/json
Accept: application/json
```

## 📋 Testing Workflow

### Step 1: Authentication
1. Create a **Register** request
2. Send the request to create a user
3. Copy the `token` from the response
4. Set the `token` environment variable in Postman

### Step 2: Test Protected Endpoints
1. Use the token in the Authorization header
2. Test various endpoints
3. Verify responses

### Step 3: Test User-Specific Data
1. Create notes and highlights
2. Check progress tracking
3. Test enrollment functionality

## 🔍 Example Test Scenarios

### Scenario 1: Complete User Journey
1. Register new user
2. Get all curricula
3. Enroll in a curriculum
4. Get chapters for the curriculum
5. Complete a chapter
6. Get lessons for the chapter
7. Complete a lesson
8. Create a note for the lesson
9. Create a highlight
10. Check progress

### Scenario 2: Error Handling
1. Try to access protected endpoint without token
2. Try to access with invalid token
3. Try to create note without required fields
4. Try to access non-existent resource

### Scenario 3: Data Validation
1. Register with invalid email
2. Register with mismatched passwords
3. Create note with empty content
4. Create highlight with invalid positions

## 📊 Expected Responses

### Success Responses
- **200 OK**: Successful GET requests
- **201 Created**: Successful POST requests
- **204 No Content**: Successful DELETE requests

### Error Responses
- **400 Bad Request**: Invalid data
- **401 Unauthorized**: Missing or invalid token
- **404 Not Found**: Resource doesn't exist
- **422 Unprocessable Entity**: Validation errors

### Error Response Format
```json
{
  "error": "Error message here"
}
```

## 🧪 Testing Tips

### 1. Use Environment Variables
- Store the base URL and token as environment variables
- This makes it easy to switch between environments

### 2. Create Test Scripts
Add this to your login request to automatically set the token:

```javascript
// Test script for login request
pm.test("Login successful", function () {
    pm.response.to.have.status(200);
});

pm.test("Token received", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.token).to.not.be.undefined;
    
    // Set the token in environment
    pm.environment.set("token", jsonData.token);
});
```

### 3. Use Pre-request Scripts
For requests that need the token, add this pre-request script:

```javascript
// Pre-request script to ensure token is set
if (!pm.environment.get("token")) {
    throw new Error("Token not found. Please login first.");
}
```

### 4. Create Collections
Organize your requests into collections:
- Authentication
- Curricula
- Chapters
- Lessons
- User Progress
- Notes
- Highlights

## 🚨 Common Issues

### 1. CORS Issues
If you get CORS errors, make sure you're using the correct domain.

### 2. Token Expiration
If you get 401 errors, your token might have expired. Re-login to get a new token.

### 3. Content-Type Issues
Make sure to set `Content-Type: application/json` for POST/PUT requests.

### 4. Missing Required Fields
Check the API documentation for required fields in request bodies.

## 📱 Mobile Testing

You can also test the API using:
- **Insomnia**: Alternative to Postman
- **cURL**: Command line testing
- **Mobile apps**: Use the same endpoints

## 🔗 Useful Links

- [Postman Documentation](https://learning.postman.com/)
- [JWT Debugger](https://jwt.io/) - To decode JWT tokens
- [JSON Formatter](https://jsonformatter.curiousconcept.com/) - To format JSON responses

## 📝 Notes

- The API uses JWT tokens that expire after a certain time
- All timestamps are in UTC
- IDs are integers
- Pagination is not implemented in this version
- File uploads are not supported in this version
