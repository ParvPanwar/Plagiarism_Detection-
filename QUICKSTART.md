# Quick Start Guide

Get your plagiarism detection system up and running in minutes!

## 🚀 Fastest Way (Docker)

```bash
# 1. Install Docker Desktop from https://www.docker.com/products/docker-desktop

# 2. Clone/navigate to project
cd "path/to/untitled folder"

# 3. Configure environment
cp backend/.env.example backend/.env
# Edit backend/.env if needed (defaults work locally)

# 4. Start everything
docker-compose up -d

# 5. Seed sample data
docker-compose exec backend npm run seed

# 6. Access the app
# Frontend: http://localhost
# Backend API: http://localhost:5000
# MongoDB: localhost:27017
# Redis: localhost:6379
```

Test credentials:
- **Admin**: admin@example.com / AdminPass123
- **Faculty**: jane.smith@university.edu / Faculty123  
- **Student**: alice.johnson@student.edu / Student123

## 💻 For Local Development

```bash
# 1. Install prerequisites
# Node.js 18+: https://nodejs.org
# MongoDB 6+: brew install mongodb-community (macOS)
# Redis 7+: brew install redis (macOS)

# 2. Setup
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. Start services (in separate terminals)
mongod
redis-server
cd backend && npm run dev

# 4. Seed database
npm run seed

# Access at: http://localhost:5000
```

## 🌐 For Production

```bash
# 1. Configure environment
cp backend/.env.example backend/.env
# Edit backend/.env with your production settings:
# - MONGODB_URI (production database)
# - JWT_SECRET (strong random string)
# - CORS_ORIGIN (your domain)
# - SSL certificates in ./ssl/

# 2. Deploy with Docker Compose
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Or manually:
docker-compose -f docker-compose.yml up -d
docker-compose exec backend npm run seed

# 3. Setup SSL with Let's Encrypt
sudo certbot certonly --standalone -d yourfomain.com
sudo cp /etc/letsencrypt/live/yourdomain.com/*.pem ./ssl/
```

## 📚 API Examples

### Register User
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

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123"
  }'
```

### Submit Assignment (with token from login)
```bash
curl -X POST http://localhost:5000/api/submissions \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "assignmentId=ASSIGNMENT_ID" \
  -F "file=@submission.pdf"
```

### Check Plagiarism Status
```bash
curl http://localhost:5000/api/analysis/SUBMISSION_ID/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🛠️ Available Commands

```bash
cd backend && npm start       # Start production server
cd backend && npm run dev     # Start with hot-reload (development)
cd backend && npm test        # Run tests
cd backend && npm run seed    # Populate database with sample data
npm run lint    # Lint code

docker-compose up -d           # Start all services
docker-compose down            # Stop all services
docker-compose logs -f backend # View backend logs
docker-compose ps              # Show running containers

# Database operations
docker-compose exec mongodb mongosh
docker-compose exec backend npm run seed
docker-compose exec mongodb mongodump --out /backup
```

## 🐛 Troubleshooting

**Backend not responding**
```bash
# Check if it's running
docker-compose ps

# View logs
docker-compose logs backend

# Restart
docker-compose restart backend
```

**Database connection error**
```bash
# Check MongoDB is running
docker-compose logs mongodb

# Restart database
docker-compose restart mongodb

# Check URI in .env
```

**Port already in use**
```bash
# Change PORT in .env
# Or free the port:
# macOS: lsof -ti:5000 | xargs kill -9
# Linux: fuser -k 5000/tcp
```

**SSL certificate error**
```bash
# Ensure certificates are in ./ssl/cert.pem and ./ssl/key.pem
# Or temporarily disable SSL in nginx.conf (development only)
```

## 📊 File Structure

```
/
├── frontend/              # Static frontend pages/assets
├── backend/               # Express API, models, services, scripts
├── scripts/               # Root helper scripts
├── docker-compose.yml     # Container setup
├── nginx.conf             # Reverse proxy
├── DEPLOYMENT.md          # Full deployment guide
└── README.md              # Project overview
```

## 📖 Next Steps

- [ ] Read [DEPLOYMENT.md](DEPLOYMENT.md) for full documentation
- [ ] Review API endpoints in routes/ folder
- [ ] Check database schemas in models/
- [ ] Setup SSL certificates for production
- [ ] Configure email (SMTP settings in .env)
- [ ] Deploy to cloud (AWS, Heroku, DigitalOcean, etc.)
- [ ] Monitor with application logs and health checks

## 🔐 Security Notes

- Never commit `.env` file with secrets
- Always use HTTPS in production
- Rotate JWT_SECRET regularly
- Keep dependencies updated: `npm audit fix`
- Monitor logs for suspicious activity
- Use strong database passwords
- Enable MongoDB authentication in production

## 📞 Support

For help:
1. Check `docker-compose logs` for error messages
2. Read the [DEPLOYMENT.md](DEPLOYMENT.md) guide
3. Check individual service logs
4. Verify all environment variables are set correctly

Happy analyzing! 🎓
