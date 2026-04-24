# API Reference Documentation

Complete API endpoints for the Plagiarism Detection System.

## Base URL

```
Development: http://localhost:5000
Production: https://yourdomain.com
```

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer {JWT_TOKEN}
```

## Response Format

All responses follow this format:

```json
{
  "success": true,
  "message": "Optional message",
  "data": {}
}
```

Error responses:

```json
{
  "success": false,
  "error": {
    "statusCode": 400,
    "message": "Error description"
  }
}
```

---

## Authentication Endpoints

### 1. Register User

**Endpoint:** `POST /api/auth/register`

**Auth Required:** No

**Request Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "userRole": "student",
  "rollNo": "2021001"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "_id": "uuid",
    "fullName": "John Doe",
    "email": "john@example.com",
    "userRole": "student"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "password": "SecurePass123",
    "userRole": "student",
    "rollNo": "2021001"
  }'
```

---

### 2. Login

**Endpoint:** `POST /api/auth/login`

**Auth Required:** No

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "_id": "uuid",
    "fullName": "John Doe",
    "email": "john@example.com",
    "userRole": "student"
  }
}
```

---

### 3. Verify Token

**Endpoint:** `POST /api/auth/verify`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "valid": true
}
```

---

### 4. Refresh Token

**Endpoint:** `POST /api/auth/refresh`

**Auth Required:** Yes

**Request Body:**
```json
{
  "refreshToken": "eyJhbGc..."
}
```

**Response:** Same as login response with new tokens

---

### 5. Logout

**Endpoint:** `POST /api/auth/logout`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## User Endpoints

### 1. Get Current User Profile

**Endpoint:** `GET /api/users/me`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "user": {
    "_id": "uuid",
    "fullName": "John Doe",
    "email": "john@example.com",
    "userRole": "student",
    "rollNo": "2021001",
    "profileImage": "url",
    "isActive": true,
    "lastLogin": "2025-01-01T12:00:00Z"
  }
}
```

---

### 2. Update User Profile

**Endpoint:** `PUT /api/users/me`

**Auth Required:** Yes

**Request Body:**
```json
{
  "fullName": "John Updated",
  "profileImage": "image_url"
}
```

---

### 3. Get All Users

**Endpoint:** `GET /api/users?userRole=student&page=1&limit=20`

**Auth Required:** Yes (Admin only)

**Query Parameters:**
- `userRole`: Filter by role (student, faculty, admin)
- `page`: Page number (default: 1)
- `limit`: Results per page (default: 20)

---

### 4. Deactivate User

**Endpoint:** `PUT /api/users/{userId}/deactivate`

**Auth Required:** Yes (Admin only)

---

### 5. Activate User

**Endpoint:** `PUT /api/users/{userId}/activate`

**Auth Required:** Yes (Admin only)

---

## Course Endpoints

### 1. Create Course

**Endpoint:** `POST /api/courses`

**Auth Required:** Yes (Admin only)

**Request Body:**
```json
{
  "courseCode": "CS101",
  "courseName": "Intro to CS",
  "description": "Basic concepts",
  "credits": 3,
  "semester": "2025-S1",
  "facultyId": "faculty_uuid"
}
```

---

### 2. Get All Courses

**Endpoint:** `GET /api/courses`

**Auth Required:** Yes

**Query Parameters:**
- `page`: Page number
- `limit`: Results per page

---

### 3. Get Faculty Courses

**Endpoint:** `GET /api/courses/faculty/my-courses`

**Auth Required:** Yes (Faculty/Admin)

---

### 4. Enroll in Course

**Endpoint:** `POST /api/courses/{courseId}/enroll`

**Auth Required:** Yes (Student)

**Response:**
```json
{
  "success": true,
  "message": "Enrolled successfully"
}
```

---

## Assignment Endpoints

### 1. Create Assignment

**Endpoint:** `POST /api/assignments`

**Auth Required:** Yes (Faculty/Admin)

**Request Body:**
```json
{
  "title": "Programming Assignment 1",
  "description": "Implement sorting algorithms",
  "courseId": "course_uuid",
  "dueDate": "2025-02-01T23:59:59Z",
  "maxMarks": 100,
  "similarityThreshold": 25
}
```

---

### 2. Get Course Assignments

**Endpoint:** `GET /api/assignments/course/{courseId}`

**Auth Required:** Yes

---

### 3. Get Assignment Details

**Endpoint:** `GET /api/assignments/{assignmentId}`

**Auth Required:** Yes

---

### 4. Update Assignment

**Endpoint:** `PUT /api/assignments/{assignmentId}`

**Auth Required:** Yes (Faculty/Admin)

---

### 5. Delete Assignment

**Endpoint:** `DELETE /api/assignments/{assignmentId}`

**Auth Required:** Yes (Faculty/Admin)

---

## Submission Endpoints

### 1. Submit Assignment

**Endpoint:** `POST /api/submissions`

**Auth Required:** Yes (Student)

**Request Format:** multipart/form-data

**Form Fields:**
- `assignmentId`: (required) Assignment UUID
- `file`: (optional) File upload (PDF, DOCX, TXT)
- `text`: (optional) Raw text submission

**Response:**
```json
{
  "success": true,
  "submission": {
    "_id": "uuid",
    "assignmentId": "uuid",
    "studentId": "uuid",
    "status": "analyzing",
    "submissionDate": "2025-01-01T12:00:00Z"
  },
  "analysisId": "uuid"
}
```

**Example:**
```bash
curl -X POST http://localhost:5000/api/submissions \
  -H "Authorization: Bearer {token}" \
  -F "assignmentId=123" \
  -F "file=@document.pdf"
```

---

### 2. Get Student Submissions

**Endpoint:** `GET /api/submissions/student?page=1&limit=20`

**Auth Required:** Yes (Student)

---

### 3. Get Course Submissions

**Endpoint:** `GET /api/submissions/course/{courseId}?page=1&limit=20`

**Auth Required:** Yes (Faculty/Admin)

---

### 4. Get Submission Details

**Endpoint:** `GET /api/submissions/{submissionId}`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "submission": {
    "_id": "uuid",
    "assignmentId": { "title": "...", ... },
    "studentId": { "fullName": "...", ... },
    "fileName": "submission.pdf",
    "fileSize": 1024000,
    "status": "completed",
    "grade": 85,
    "feedback": "Great work!",
    "isLate": false,
    "submissionDate": "2025-01-01T12:00:00Z"
  }
}
```

---

### 5. Grade Submission

**Endpoint:** `PUT /api/submissions/{submissionId}/grade`

**Auth Required:** Yes (Faculty/Admin)

**Request Body:**
```json
{
  "grade": 85,
  "feedback": "Excellent work!"
}
```

---

### 6. Delete Submission

**Endpoint:** `DELETE /api/submissions/{submissionId}`

**Auth Required:** Yes

---

## Analysis Endpoints

### 1. Check Plagiarism

**Endpoint:** `POST /api/analysis/check`

**Auth Required:** Yes

**Request Body:**
```json
{
  "submissionId": "uuid"
}
```

**Response:**
```json
{
  "success": true,
  "analysisId": "uuid",
  "status": "analyzing"
}
```

---

### 2. Get Analysis Status

**Endpoint:** `GET /api/analysis/{submissionId}/status`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "status": "completed",
  "report": {
    "similarityScore": 25,
    "riskLevel": "low",
    "analysisTime": 2500
  }
}
```

---

### 3. Batch Analysis

**Endpoint:** `POST /api/analysis/batch`

**Auth Required:** Yes (Faculty/Admin)

**Request Body:**
```json
{
  "submissionIds": ["uuid1", "uuid2", "uuid3"]
}
```

---

## Report Endpoints

### 1. Get Plagiarism Report

**Endpoint:** `GET /api/reports/submission/{submissionId}`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "report": {
    "_id": "uuid",
    "submissionId": "uuid",
    "studentId": "uuid",
    "similarityScore": 25,
    "riskLevel": "low",
    "matchedSources": [
      {
        "submissionId": "uuid",
        "studentName": "Jane Doe",
        "similarity": 20
      }
    ],
    "flaggedSections": [
      {
        "text": "Matched text...",
        "position": 100,
        "length": 50
      }
    ],
    "totalMatches": 5,
    "uniqueMatches": 3,
    "analysisTime": 2500,
    "algorithm": "combined",
    "reviewed": false,
    "reviewNotes": null,
    "createdAt": "2025-01-01T12:00:00Z"
  }
}
```

---

### 2. Get Course Reports

**Endpoint:** `GET /api/reports/course/{courseId}?page=1&limit=20`

**Auth Required:** Yes (Faculty/Admin)

---

### 3. Mark Report as Reviewed

**Endpoint:** `PUT /api/reports/{reportId}/review`

**Auth Required:** Yes (Faculty/Admin)

**Request Body:**
```json
{
  "reviewed": true,
  "reviewNotes": "Reviewed and accepted. Within acceptable limits."
}
```

---

### 4. Get Flagged Reports

**Endpoint:** `GET /api/reports?riskLevel=high,critical&reviewed=false&page=1&limit=20`

**Auth Required:** Yes (Faculty/Admin)

**Query Parameters:**
- `riskLevel`: Comma-separated risk levels (low, medium, high, critical)
- `reviewed`: Filter by review status (true/false)
- `page`: Page number
- `limit`: Results per page

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Server Error |

---

## Error Examples

### Invalid Email
```json
{
  "success": false,
  "error": {
    "statusCode": 400,
    "message": "Please enter a valid email address"
  }
}
```

### Token Expired
```json
{
  "success": false,
  "error": {
    "statusCode": 401,
    "message": "Token has expired"
  }
}
```

### Insufficient Permissions
```json
{
  "success": false,
  "error": {
    "statusCode": 403,
    "message": "You do not have permission to perform this action"
  }
}
```

---

## Best Practices

**Token Management:**
- Store token in localStorage or sessionStorage
- Include Authorization header with every request
- Refresh token before expiry using /api/auth/refresh
- Clear tokens on logout

**File Uploads:**
- Maximum file size: 10MB
- Allowed formats: PDF, DOCX, TXT only
- Always validate on client side
- Use multipart/form-data for uploads

**Error Handling:**
- Always check `success` field
- Log errors for debugging
- Display user-friendly messages
- Redirect to login on 401 errors

**Rate Limiting:**
- Implement client-side request debouncing
- Respect server rate limits
- Use exponential backoff for retries

---

## Testing with cURL

### Register
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John",
    "email": "john@example.com",
    "password": "Pass123",
    "userRole": "student",
    "rollNo": "2021001"
  }'
```

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "Pass123"
  }'
```

### Protected Request
```bash
curl -X GET http://localhost:5000/api/users/me \
  -H "Authorization: Bearer {TOKEN}"
```

---

## Testing with Postman

1. Import the API collection
2. Set base_url environment variable
3. Use {{base_url}} in requests
4. Store token in postman_token variable
5. Use {{postman_token}} in Authorization header

---

## WebSocket Events

Real-time updates via Socket.IO:

```javascript
const socket = io('http://localhost:5000', {
  auth: {
    token: authToken
  }
});

// Listen for analysis progress
socket.on('analysis:progress', (data) => {
  console.log('Analysis status:', data.status);
});

// Listen for completion
socket.on('analysis:complete', (data) => {
  console.log('Report:', data.report);
});
```

---

*Last Updated: 2025*
*API Version: 1.0.0*
