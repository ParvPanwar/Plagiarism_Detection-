# Plagiarism Detection System - Complete Deployment Guide

## Overview

A production-ready plagiarism detection system built with Node.js, Express, MongoDB, and Socket.IO. This guide covers installation, configuration, and deployment.

## Technology Stack

- **Backend**: Node.js 18+ with Express.js
- **Database**: MongoDB 6.0+
- **Cache**: Redis 7.0+
- **Frontend**: HTML, CSS, JavaScript (Vanilla)
- **Reverse Proxy**: Nginx
- **Containerization**: Docker & Docker Compose
- **Authentication**: JWT with refresh tokens
- **Real-time**: Socket.IO

## Project Structure

```
.
├── server.js                 # Main application entry point
├── package.json             # Dependencies and scripts
├── .env                     # Environment configuration
├── Dockerfile              # Docker image configuration
├── docker-compose.yml      # Multi-container setup
├── nginx.conf              # Reverse proxy configuration
│
├── models/                 # Database schemas
│   └── index.js
│
├── routes/                 # API endpoints
│   ├── auth.js            # Authentication endpoints
│   ├── submissions.js      # File upload and submissions
│   ├── assignments.js      # Assignment management
│   ├── courses.js          # Course management
│   ├── reports.js          # Plagiarism reports
│   ├── users.js            # User management
│   └── analysis.js         # Analysis endpoints
│
├── middleware/             # Express middleware
│   └── auth.js            # JWT authentication
│
├── services/               # Business logic
│   └── plagiarismService.js
│
├── utils/                  # Utility functions
│   └── plagiarismUtils.js
│
├── uploads/               # User-uploaded files (created at runtime)
├── logs/                  # Application logs (created at runtime)
│
└── Frontend HTML files:
    ├── index.html
    ├── login.html
    ├── register.html
    ├── student-dashboard.html
    ├── faculty-dashboard.html
    ├── admin-dashboard.html
    ├── script.js
    ├── auth.js
    └── styles.css
```

## Prerequisites

### For Local Development
- Node.js 18.0.0 or higher
- npm 8.0.0 or higher
- MongoDB 6.0 or higher
- Redis 7.0 or higher

### For Docker Deployment
- Docker 20.10+
- Docker Compose 2.0+

## Installation & Setup

### Option 1: Local Development

1. **Clone and setup:**
```bash
cd "path/to/untitled folder"
npm install
```

2. **Configure environment:**
```bash
cp .env.example .env
# Edit .env with your settings
```

3. **Start MongoDB locally:**
```bash
# On macOS with Homebrew
brew services start mongodb-community@6.0

# Or with Docker
docker run -d -p 27017:27017 --name mongodb mongo:6.0
```

4. **Start Redis locally:**
```bash
# On macOS with Homebrew
brew services start redis

# Or with Docker
docker run -d -p 6379:6379 --name redis redis:7-alpine
```

5. **Initialize database:**
```bash
npm run seed
# This will populate sample data
```

6. **Start development server:**
```bash
npm run dev
# Server runs on http://localhost:5000
```

### Option 2: Docker Deployment

1. **Prepare environment:**
```bash
cd "path/to/untitled folder"
cp .env.example .env
# Edit .env with production settings
```

2. **Build and start with Docker Compose:**
```bash
docker-compose up -d
```

This starts:
- Backend API on port 5000
- MongoDB on port 27017
- Redis on port 6379
- Nginx reverse proxy on ports 80/443

3. **Verify services:**
```bash
# Check running containers
docker-compose ps

# Check logs
docker-compose logs backend
```

## API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "userRole": "student",
  "rollNo": "2021001"
}

Response:
{
  "success": true,
  "token": "jwt-token",
  "refreshToken": "refresh-token",
  "user": { ... }
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}

Response: Same as register
```

#### Verify Token
```http
POST /api/auth/verify
Authorization: Bearer {token}

Response:
{
  "success": true,
  "valid": true
}
```

### Submission Endpoints

#### Submit Assignment
```http
POST /api/submissions
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form data:
- assignmentId: string
- file: File (optional - PDF/DOCX/TXT)
- text: string (optional - raw text)

Response:
{
  "success": true,
  "submission": { ... },
  "analysisId": "uuid"
}
```

#### Get Student Submissions
```http
GET /api/submissions/student
Authorization: Bearer {token}

Response:
{
  "success": true,
  "submissions": [ ... ]
}
```

#### Get Course Submissions
```http
GET /api/submissions/course/{courseId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "submissions": [ ... ]
}
```

### Analysis Endpoints

#### Check Plagiarism
```http
POST /api/analysis/check
Authorization: Bearer {token}
Content-Type: application/json

{
  "submissionId": "uuid"
}

Response:
{
  "success": true,
  "analysisId": "uuid",
  "status": "analyzing"
}
```

#### Get Analysis Status
```http
GET /api/analysis/{submissionId}/status
Authorization: Bearer {token}

Response:
{
  "success": true,
  "status": "completed",
  "report": { ... }
}
```

### Report Endpoints

#### Get Plagiarism Report
```http
GET /api/reports/submission/{submissionId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "report": {
    "similarityScore": 25,
    "riskLevel": "low",
    "matchedSources": [ ... ]
  }
}
```

#### Get Course Reports
```http
GET /api/reports/course/{courseId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "reports": [ ... ]
}
```

## Security Considerations

### Environment Variables
Never commit `.env` file to version control. Always use strong secrets:
- JWT_SECRET: minimum 32 characters, random
- Database passwords: complex and unique
- API keys: regenerated regularly

### SSL/TLS Certificates

For production, obtain SSL certificates:

```bash
# Using Let's Encrypt (free)
sudo apt-get install certbot
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates to ./ssl directory
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
```

### Security Headers
Nginx configuration includes:
- Strict-Transport-Security
- X-Content-Type-Options
- X-Frame-Options
- X-XSS-Protection
- Content Security Policy (CSP)

### Input Validation
All endpoints validate and sanitize input using express-validator:
- Email format validation
- File type validation
- File size limits (10MB default)
- XSS prevention

### Password Security
- Bcrypt hashing with 10 rounds
- Minimum 8 characters with uppercase, lowercase, and numbers
- Password never returned in responses

## Monitoring & Maintenance

### Health Check
```bash
curl http://localhost:5000/health
# Response: { "status": "ok" }
```

### Docker Logs
```bash
docker-compose logs -f backend
docker-compose logs -f mongodb
docker-compose logs -f redis
```

### Database Backup
```bash
# Export database
docker-compose exec mongodb mongodump --out /backup

# Restore database
docker-compose exec mongodb mongorestore /backup
```

### Redis Cache Clear
```bash
docker-compose exec redis redis-cli FLUSHALL
```

## Performance Optimization

### Database Indexes
Key indexes are created automatically on:
- User.email (unique)
- Course.courseCode (unique)
- Assignment.courseId
- Submission.assignmentId, studentId
- Token.submissionId, token
- Report.submissionId

### Caching Strategy
- User profiles cached for 1 hour
- Course data cached for 6 hours
- Analysis results cached for 24 hours
- Redis TTL configured in environment

### File Upload Optimization
- Maximum file size: 10MB (configurable)
- Allowed formats: PDF, DOCX, TXT
- Async processing with job queue
- Files stored on disk or S3

## Troubleshooting

### MongoDB Connection Error
```
Solution: Verify MONGODB_URI in .env
docker-compose logs mongodb
```

### JWT Token Expired
```
Solution: Refresh token using /api/auth/refresh
Client automatically stores and uses refreshToken
```

### File Upload Fails
```
Solution: Check MAX_FILE_SIZE and file format
Allowed: .pdf, .docx, .txt only
Size: Max 10MB (configurable)
```

### Analysis Stuck on "Analyzing"
```
Solution: Check backend logs and restart service
docker-compose restart backend
```

## Deployment Checklist

Before production deployment:

- [ ] Update `.env` with production values
- [ ] Change JWT_SECRET to strong random value
- [ ] Configure MongoDB with authentication
- [ ] Enable Redis password
- [ ] Set up SSL certificates
- [ ] Configure CORS_ORIGIN to your domain
- [ ] Set NODE_ENV=production
- [ ] Enable HTTPS in nginx.conf
- [ ] Test all endpoints with Postman/curl
- [ ] Setup database backups
- [ ] Configure logging
- [ ] Setup monitoring/alerts
- [ ] Test on staging environment first

## Scaling Considerations

### Horizontal Scaling
- **Load Balancer**: Use AWS ALB, Nginx, or HAProxy
- **Session Management**: JWT makes it stateless
- **Database**: MongoDB replica set for HA
- **Cache**: Redis cluster for distributed caching

### Vertical Scaling
- **Worker Processes**: Configured via Nginx worker_processes
- **Node.js Cluster**: Can be added to server.js
- **Memory**: Monitor with `docker stats`
- **CPU**: Add analysis queue processing workers

## Support & Documentation

- **API Docs**: Available at `http://localhost:5000/api-docs` (Swagger)
- **Issues**: Check application logs in `./logs`
- **Frontend**: HTML files are self-contained
- **Postman Collection**: Import from `postman-collection.json`

## License

This project is proprietary software for educational institutions.

## Support Contact

For deployment issues:
1. Check logs: `docker-compose logs`
2. Verify environment variables: `docker-compose exec backend env`
3. Test API: `curl http://localhost:5000/health`

---

**Last Updated**: 2025
**Version**: 1.0.0
**Status**: Production Ready
