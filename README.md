# Plagiarism Detection System - Complete Frontend Website

A modern, production-ready web application for detecting academic plagiarism with comprehensive dashboards for students, faculty, and administrators.

## 📁 Project Structure

```
plagiarism-detection-system/
├── frontend/
│   ├── index.html                # Landing page
│   ├── login.html                # User login
│   ├── register.html             # User registration
│   ├── student-dashboard.html    # Student interface
│   ├── faculty-dashboard.html    # Faculty interface
│   ├── admin-dashboard.html      # Admin interface
│   ├── styles.css                # Shared styles
│   ├── script.js                 # Dashboard functionality
│   └── auth.js                   # Frontend auth helpers
├── backend/
│   ├── server.js                 # Express entry point
│   ├── routes/                   # API routes
│   ├── models/                   # Mongoose schemas
│   ├── services/                 # Business logic
│   ├── middleware/               # Auth middleware
│   ├── utils/                    # Utility helpers
│   ├── scripts/                  # Backend scripts
│   └── package.json              # Backend dependencies
└── README.md                     # This file
```

## 🎯 Features

### **Landing Page (index.html)**
- Professional marketing design
- Feature showcase
- Pricing plans
- Call-to-action sections
- Responsive hero section
- How it works section

### **Authentication System**
- **Login Page**: Secure authentication with email/password
- **Registration Page**: Multi-role signup (Student, Faculty, Admin)
- Google OAuth integration ready
- Password validation and strength checking
- Remember me functionality
- Error handling and validation

### **Student Dashboard (student-dashboard.html)**
- View assigned assignments
- Submit work for analysis
- Track submission history
- View plagiarism reports with detailed analysis
- Grade tracking
- Course enrollment management
- Message system for instructor communication
- Download reports

### **Faculty Dashboard (faculty-dashboard.html)**
- Manage multiple courses
- Create and manage assignments
- View all student submissions
- Analyze plagiarism reports
- Flag suspicious submissions
- Send alerts to students
- Export submission data
- Batch processing capabilities
- Analytics and statistics

### **Admin Dashboard (admin-dashboard.html)**
- System-wide analytics
- User management (Faculty and Students)
- Course management
- System settings configuration
- Security controls
- Database and backup management
- Server performance monitoring
- Access control management
- API usage statistics

## 🎨 Design Features

- **Modern UI/UX**: Clean, professional interface with intuitive navigation
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- **Dark Mode Support**: Theme toggle for light and dark modes
- **Accessibility**: WCAG compliant with keyboard navigation and screen reader support
- **Performance Optimized**: Fast loading with optimized CSS and JavaScript
- **Professional Color Scheme**: Teal primary color with complementary palette
- **Smooth Animations**: Subtle transitions and interactions

## 🔐 Security Features

- Token-based authentication (JWT)
- Role-based access control (RBAC)
- Password strength validation
- Secure file upload handling
- HTTPS support
- Two-factor authentication ready
- Session management
- CSRF protection ready

## 📊 Key Dashboard Sections

### **Student Features**
- Assignment submission
- Real-time plagiarism analysis
- Submission history
- Grade viewing
- Report generation
- Course materials access

### **Faculty Features**
- Assignment creation
- Batch submission analysis
- Plagiarism report generation
- Student alerts
- Grade management
- Class management
- Export capabilities

### **Admin Features**
- Complete system monitoring
- User management
- System configuration
- Server health monitoring
- Database management
- Security settings
- Analytics and reporting

## 🚀 Getting Started

### Prerequisites
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Backend server (Node.js, Python, or Java)
- Database (MySQL, PostgreSQL)

### Installation

1. **Extract the project files** to your web server directory

2. **Configure the API endpoint** in `script.js` and `auth.js`:
   ```javascript
   const API_BASE = 'http://your-backend-url/api';
   ```

3. **Set up the database** using `plagiarism_detection.sql`:
   ```bash
   mysql -u username -p database_name < plagiarism_detection.sql
   ```

4. **Launch in your browser**:
   - For local testing: Open `index.html` in your browser
   - For production: Deploy to a web server (Apache, Nginx)

## 🔧 Backend API Requirements

The frontend expects the following API endpoints:

### Authentication Endpoints
```
POST   /api/auth/login           - User login
POST   /api/auth/register        - User registration
POST   /api/auth/verify          - Token verification
POST   /api/auth/refresh         - Token refresh
POST   /api/auth/logout          - User logout
```

### Submission Endpoints
```
GET    /api/submissions          - Get all submissions
POST   /api/submissions          - Create new submission
GET    /api/submissions/:id      - Get submission details
PUT    /api/submissions/:id      - Update submission
DELETE /api/submissions/:id      - Delete submission
```

### Analysis Endpoints
```
POST   /api/analysis/check       - Analyze for plagiarism
GET    /api/analysis/:id         - Get analysis report
POST   /api/analysis/batch       - Batch process submissions
```

### Assignment Endpoints
```
GET    /api/assignments          - List all assignments
POST   /api/assignments          - Create assignment
GET    /api/assignments/:id      - Get assignment details
PUT    /api/assignments/:id      - Update assignment
DELETE /api/assignments/:id      - Delete assignment
```

### Course Endpoints
```
GET    /api/courses              - List all courses
POST   /api/courses              - Create course
GET    /api/courses/:id          - Get course details
PUT    /api/courses/:id          - Update course
DELETE /api/courses/:id          - Delete course
```

### User Endpoints
```
GET    /api/users                - List users (admin)
GET    /api/users/:id            - Get user details
PUT    /api/users/:id            - Update user
DELETE /api/users/:id            - Delete user
```

## 📝 API Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## 🗄️ Database Schema Overview

### Tables
- **FACULTY**: Faculty member information
- **COURSE**: Course details and faculty assignments
- **STUDENT**: Student profiles and enrollment
- **ASSIGNMENT**: Assignment specifications
- **SUBMISSION**: Student submissions
- **TOKEN**: Tokenized words from submissions
- **PLAGIARISM_REPORT**: Plagiarism analysis reports

## 🎯 Authentication Flow

1. User navigates to `login.html` or `register.html`
2. Credentials are validated on the frontend
3. API request sent to backend
4. Backend validates and returns JWT token
5. Token stored in localStorage
6. User redirected to appropriate dashboard based on role
7. All subsequent requests include token in Authorization header

## 🔄 Plagiarism Detection Workflow

1. Student submits assignment via upload or text
2. File is sent to backend for processing
3. Backend tokenizes the content
4. Tokens compared against database and external sources
5. Similarity percentage calculated
6. Report generated with matched sections
7. Results displayed to student and faculty
8. Administrative alerts if threshold exceeded

## ⚙️ Configuration

### Customize Thresholds
Edit settings in Faculty/Admin dashboards:
- Similarity threshold (default: 50%)
- Minimum word match (default: 5 words)
- External source matching (enabled/disabled)

### Theme Customization
Modify CSS variables in `styles.css`:
```css
:root {
  --color-primary: #01696f;      /* Primary brand color */
  --color-success: #437a22;      /* Success indicator */
  --color-error: #9c2b70;        /* Error indicator */
  /* ... more variables ... */
}
```

## 📱 Responsive Breakpoints

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

## ♿ Accessibility

- Semantic HTML5 structure
- ARIA labels and roles
- Keyboard navigation support
- Focus indicators
- Color contrast compliance
- Screen reader friendly
- Skip-to-content links

## 🔍 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
- Mobile browsers (iOS Safari, Chrome Mobile)

## 📦 Dependencies

- **Chart.js 3.9.1** - Data visualization
- **Font Awesome 6.4.0** - Icons
- **Google Fonts** - Typography

All dependencies are loaded from CDN.

## 🚀 Deployment

### Development
```bash
# Serve locally with Python
python -m http.server 8000

# Or use Node.js
npx http-server
```

### Production
1. Optimize images and assets
2. Minify CSS and JavaScript
3. Set up HTTPS (SSL/TLS)
4. Configure CORS properly
5. Deploy to cloud (AWS, Azure, GCP)
6. Set up CDN for static assets
7. Configure environment variables

## 🐛 Troubleshooting

### API Connection Issues
- Check API endpoint in script.js
- Verify backend is running
- Check CORS configuration
- Review browser console for errors

### Login/Authentication Issues
- Clear browser cache and cookies
- Check localStorage is enabled
- Verify JWT token format
- Check token expiration

### Submission Upload Issues
- Check maximum file size (10MB)
- Verify file format is supported
- Check server disk space
- Review file permissions

## 📊 Usage Statistics

Track system usage:
- Total submissions analyzed
- Average similarity score
- Flagged submissions
- User engagement metrics
- System performance metrics

## 🔐 Security Best Practices

1. Use HTTPS in production
2. Validate all inputs server-side
3. Sanitize file uploads
4. Implement rate limiting
5. Use strong password policies
6. Regular security audits
7. Keep dependencies updated
8. Implement logging and monitoring

## 📞 Support & Documentation

For detailed API documentation, see the backend repository.

### Common Issues
- **Token expired**: Re-login required
- **File too large**: Upload files under 10MB
- **Similarity calculation**: Uses Jaccard similarity algorithm
- **Report generation**: Can take 5-10 seconds for large submissions

## 📄 License

This is an academic project for UCS310 - Database Management Systems course at Thapar Institute of Engineering Technology.

## 👥 Credits

**Developed by:**
- Parv Panwar (1024030226)
- Manan Dhingra (1024030222)

**Course:** UCS310 - Database Management Systems
**Institute:** COE, Thapar Institute of Engineering Technology
**Year:** 2025-2026

## 🔄 Version History

- **v1.0** (2025-04-23): Initial release with full functionality
  - Landing page
  - Authentication system
  - Student dashboard
  - Faculty dashboard
  - Admin dashboard
  - Responsive design
  - Dark mode support

## 📝 Future Enhancements

- Mobile app (React Native)
- Advanced analytics dashboard
- Machine learning integration for pattern detection
- Plagiarism trend analysis
- Custom rule creation
- Source database expansion
- Integration with learning management systems (LMS)
- Plagiarism trend tracking
- Advanced report generation
- Batch email notifications

## 📞 Contact

For questions or support:
- Email: student@university.edu
- Support Portal: Available in settings
- Documentation: `/docs` folder

---

**Note:** This is a complete frontend solution. Backend development is required for full functionality. See `plagiarism_detection.sql` for database schema and implement corresponding APIs.
