// auth.js - Authentication Module

// Check if user is logged in
function checkAuth() {
  const token = localStorage.getItem('authToken');
  const userRole = localStorage.getItem('userRole');
  
  if (!token || !userRole) {
    // Redirect to login if not on auth pages
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    if (!['login.html', 'register.html', 'forgot-password.html', 'index.html'].includes(currentPage)) {
      window.location.href = 'login.html';
    }
  }
}

// Initialize authentication check
document.addEventListener('DOMContentLoaded', checkAuth);

// Validate password strength
function validatePasswordStrength(password) {
  const strength = {
    hasUpperCase: /[A-Z]/.test(password),
    hasLowerCase: /[a-z]/.test(password),
    hasNumbers: /\d/.test(password),
    hasMinLength: password.length >= 8
  };

  return Object.values(strength).every(val => val);
}

// Form validation
function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

// Clear form errors
function clearFormErrors(form) {
  form.querySelectorAll('.error-message').forEach(el => {
    el.textContent = '';
  });
}

// Show field error
function showFieldError(fieldId, message) {
  const errorEl = document.getElementById(fieldId + 'Error');
  if (errorEl) {
    errorEl.textContent = message;
  }
}

// API Configuration
const API_BASE = window.getApiBase();

function normalizeAuthResponse(data) {
  const user = data.user || {};

  return {
    token: data.token,
    refreshToken: data.refreshToken,
    userId: data.userId || user.id || user._id,
    userName: data.userName || user.fullName,
    userRole: data.userRole || user.userRole,
    email: user.email
  };
}

// Login request
async function login(email, password) {
  try {
    const response = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });

    const data = await response.json();

    if (response.ok) {
      const authData = normalizeAuthResponse(data);

      // Store auth data
      localStorage.setItem('authToken', authData.token);
      localStorage.setItem('userRole', authData.userRole);
      localStorage.setItem('userName', authData.userName);
      localStorage.setItem('userId', authData.userId);
      
      return { success: true, data: authData };
    } else {
      return { success: false, error: data.message };
    }
  } catch (error) {
    return { success: false, error: 'Network error' };
  }
}

// Register request
async function register(formData) {
  try {
    const response = await fetch(`${API_BASE}/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(formData)
    });

    const data = await response.json();

    if (response.ok) {
      return { success: true, data: normalizeAuthResponse(data) };
    } else {
      return { success: false, error: data.message };
    }
  } catch (error) {
    return { success: false, error: 'Network error' };
  }
}

// Logout
function logout() {
  localStorage.removeItem('authToken');
  localStorage.removeItem('userRole');
  localStorage.removeItem('userName');
  localStorage.removeItem('userId');
  window.location.href = 'login.html';
}

// Get authorization header
function getAuthHeader() {
  const token = localStorage.getItem('authToken');
  return {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };
}

// Check if user is logged in
function isLoggedIn() {
  return !!localStorage.getItem('authToken');
}

// Get user role
function getUserRole() {
  return localStorage.getItem('userRole');
}

// Check user role
function hasRole(role) {
  const userRole = getUserRole();
  if (Array.isArray(role)) {
    return role.includes(userRole);
  }
  return userRole === role;
}

// Verify token and refresh if needed
async function verifyToken() {
  const token = localStorage.getItem('authToken');
  
  if (!token) {
    return false;
  }

  try {
    const response = await fetch(`${API_BASE}/auth/verify`, {
      headers: getAuthHeader()
    });

    if (response.ok) {
      return true;
    } else if (response.status === 401) {
      logout();
      return false;
    }
  } catch (error) {
    console.error('Token verification error:', error);
    return false;
  }
}

// Refresh token
async function refreshToken() {
  try {
    const response = await fetch(`${API_BASE}/auth/refresh`, {
      method: 'POST',
      headers: getAuthHeader()
    });

    const data = await response.json();

    if (response.ok) {
      localStorage.setItem('authToken', data.token);
      return true;
    } else {
      logout();
      return false;
    }
  } catch (error) {
    console.error('Token refresh error:', error);
    logout();
    return false;
  }
}

// Periodically verify token (every 5 minutes)
const tokenVerifyInterval = setInterval(verifyToken, 5 * 60 * 1000);

// Alert before logout on session timeout
window.addEventListener('beforeunload', function() {
  clearInterval(tokenVerifyInterval);
});
