# 🚀 Quick Reference Card

## Essential Commands

### Start Development
```bash
docker-compose up -d
docker-compose exec backend npm run seed
# Visit: http://localhost
```

### Start Production
```bash
docker-compose -f docker-compose.yml up -d
# Already configured for production
```

### View Logs
```bash
docker-compose logs -f backend      # Backend
docker-compose logs -f mongodb      # Database
docker-compose logs -f redis        # Cache
docker-compose logs -f nginx        # Web server
```

### Stop Services
```bash
docker-compose down                 # Stop all
docker-compose restart backend      # Restart one
docker-compose stop mongodb         # Pause one
```

### Database Operations
```bash
docker-compose exec backend npm run seed      # Add sample data
docker-compose exec mongodb mongosh           # Connect to database
docker-compose exec mongodb mongodump --out /backup  # Backup database
```

### Test API
```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

---

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | AdminPass123 |
| Faculty | jane.smith@university.edu | Faculty123 |
| Student | alice.johnson@student.edu | Student123 |

---

## Important URLs

| Service | URL |
|---------|-----|
| Frontend | http://localhost |
| Backend API | http://localhost:5000 |
| MongoDB | localhost:27017 |
| Redis | localhost:6379 |
| Health Check | http://localhost:5000/health |

---

## API Endpoints (Quick List)

### Auth
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login
- `POST /api/auth/verify` - Verify token

### Users
- `GET /api/users/me` - Get profile
- `PUT /api/users/me` - Update profile

### Courses
- `POST /api/courses` - Create course
- `GET /api/courses` - List courses
- `POST /api/courses/:id/enroll` - Enroll

### Assignments
- `POST /api/assignments` - Create
- `GET /api/assignments/course/:id` - List
- `PUT /api/assignments/:id` - Update

### Submissions
- `POST /api/submissions` - Submit
- `GET /api/submissions/student` - My submissions
- `PUT /api/submissions/:id/grade` - Grade

### Analysis
- `POST /api/analysis/check` - Analyze
- `GET /api/analysis/:id/status` - Check status

### Reports
- `GET /api/reports/submission/:id` - Get report
- `GET /api/reports/course/:id` - Course reports

---

## Environment Variables

### Critical (Change These!)
```
JWT_SECRET=your-super-secret-key-min-32-chars
MONGODB_URI=mongodb://mongodb:27017/plagiarism_detection
CORS_ORIGIN=https://yourdomain.com
```

### Optional
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

---

## File Structure

```
.
├── Backend
│   ├── server.js
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   └── utils/
│
├── Frontend
│   ├── *.html (6 pages)
│   ├── script.js
│   ├── auth.js
│   └── styles.css
│
├── Deployment
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx.conf
│   └── ecosystem.config.js
│
└── Documentation
    ├── QUICKSTART.md
    ├── DEPLOYMENT.md
    ├── API_REFERENCE.md
    └── PROJECT_SUMMARY.md
```

---

## Common Issues & Solutions

### Issue: "Connection refused"
```bash
# Solution: Start services
docker-compose up -d
```

### Issue: "Port already in use"
```bash
# Solution: Change PORT in .env or free port
# macOS: lsof -ti:5000 | xargs kill -9
```

### Issue: "JWT_SECRET not set"
```bash
# Solution: Copy .env.example to .env
cp .env.example .env
```

### Issue: Files in uploads/ deleted
```bash
# Solution: Docker volumes persist but can be cleaned
docker-compose down -v    # Caution: removes data!
```

---

## Deployment Checklist

- [ ] Update .env with production values
- [ ] Set strong JWT_SECRET
- [ ] Configure SSL certificates in ./ssl/
- [ ] Update CORS_ORIGIN
- [ ] Test with scripts/test-api.sh
- [ ] Run database backup
- [ ] Check docker-compose logs
- [ ] Verify health check: curl /health
- [ ] Load test under expected traffic
- [ ] Setup monitoring
- [ ] Document access credentials

---

## Node.js Commands

```bash
npm install              # Install dependencies
npm start               # Start server (production)
npm run dev            # Start with hot-reload
npm test               # Run tests
npm run seed           # Seed database
npm run lint           # Lint code
```

---

## Key Features

✅ 40+ API endpoints
✅ JWT authentication
✅ Role-based access control (3 roles)
✅ Plagiarism detection algorithm
✅ File upload with validation
✅ Real-time updates with Socket.IO
✅ MongoDB database
✅ Redis caching
✅ Docker containerization
✅ Nginx reverse proxy
✅ SSL/TLS support
✅ Comprehensive documentation

---

## Performance Tips

1. Use Redis for caching
2. Enable gzip compression (configured)
3. Use CDN for static files (ready)
4. Monitor database queries
5. Scale horizontally with load balancer
6. Keep MongoDB indexes updated
7. Archive old reports

---

## Security Checklist

- [ ] Use HTTPS in production
- [ ] Strong JWT_SECRET
- [ ] Database authentication enabled
- [ ] Redis password set
- [ ] Input validation on all endpoints
- [ ] File upload validation
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Security headers enabled
- [ ] Logs monitored for attacks

---

## Reference Links

- Node.js: https://nodejs.org
- Express: https://expressjs.com
- MongoDB: https://www.mongodb.com
- Docker: https://www.docker.com
- JWT: https://jwt.io
- Socket.IO: https://socket.io

---

## Support Resources

1. **QUICKSTART.md** - 5-minute setup
2. **DEPLOYMENT.md** - Full deployment guide
3. **API_REFERENCE.md** - All endpoints
4. **scripts/test-api.sh** - Test everything
5. **docker-compose logs** - Debugging

---

**Last Updated:** 2025
**Version:** 1.0.0
**Status:** ✅ Production Ready

Everything you need is here. Ready to deploy! 🚀
