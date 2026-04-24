// main.js - Main Dashboard Functionality

document.addEventListener('DOMContentLoaded', function() {
  initializeDashboard();
  setupCharts();
  setupMenuNavigation();
  setupThemeToggle();
});

// Initialize Dashboard
function initializeDashboard() {
  const savedSection = localStorage.getItem('activeSection') || 'dashboard';
  showSection(savedSection);
  updateUserInfo();
}

// Section Navigation
function showSection(sectionId) {
  // Hide all sections
  document.querySelectorAll('.content-section').forEach(section => {
    section.classList.remove('active');
  });

  // Remove active class from all menu links
  document.querySelectorAll('.menu-link').forEach(link => {
    link.classList.remove('active');
  });

  // Show selected section
  const section = document.getElementById(sectionId);
  if (section) {
    section.classList.add('active');
    localStorage.setItem('activeSection', sectionId);
  }

  // Highlight menu link
  const menuLink = document.querySelector(`a[href="#${sectionId}"]`);
  if (menuLink) {
    menuLink.classList.add('active');
  }
}

// Setup Menu Navigation
function setupMenuNavigation() {
  document.querySelectorAll('.menu-link').forEach(link => {
    link.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      if (href && href.startsWith('#')) {
        e.preventDefault();
        showSection(href.substring(1));
      }
    });
  });
}

// Update User Information
function updateUserInfo() {
  const userRole = localStorage.getItem('userRole');
  const userName = localStorage.getItem('userName');
  
  const userDisplay = document.querySelector('.dropdown-btn');
  if (userDisplay && userName) {
    userDisplay.textContent = `${userName} ${userRole}`;
  }
}

// Charts Setup
function setupCharts() {
  if (document.getElementById('submissionChart')) {
    setupSubmissionChart();
  }
  if (document.getElementById('plagiarismChart')) {
    setupPlagiarismChart();
  }
}

// Submission Trend Chart
function setupSubmissionChart() {
  const ctx = document.getElementById('submissionChart').getContext('2d');
  
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      datasets: [
        {
          label: 'Submissions',
          data: [65, 78, 90, 81, 95, 110, 125],
          borderColor: '#01696f',
          backgroundColor: 'rgba(1, 105, 111, 0.1)',
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#01696f',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 5,
          pointHoverRadius: 8,
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: {
          display: true,
          labels: {
            color: '#26231d',
            font: { size: 12, weight: 600 }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: {
            color: 'rgba(0, 0, 0, 0.05)',
          },
          ticks: {
            color: '#706d67',
            font: { size: 12 }
          }
        },
        x: {
          grid: {
            display: false,
          },
          ticks: {
            color: '#706d67',
            font: { size: 12 }
          }
        }
      }
    }
  });
}

// Plagiarism Distribution Chart
function setupPlagiarismChart() {
  const ctx = document.getElementById('plagiarismChart').getContext('2d');
  
  new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['Clean (0-25%)', 'Moderate (25-50%)', 'High (50-75%)', 'Critical (75-100%)'],
      datasets: [{
        data: [1201, 85, 47, 15],
        backgroundColor: [
          '#437a22',
          '#a55b21',
          '#d97706',
          '#991b1b'
        ],
        borderColor: '#ffffff',
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: {
          position: 'bottom',
          labels: {
            color: '#26231d',
            font: { size: 12, weight: 600 },
            padding: 15
          }
        }
      }
    }
  });
}

// Modal Functions
function showModal(modalId) {
  const modal = document.getElementById(modalId + 'Modal');
  if (modal) {
    modal.classList.add('active');
  }
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId + 'Modal');
  if (modal) {
    modal.classList.remove('active');
  }
}

// Close modal when clicking outside
document.addEventListener('click', function(event) {
  if (event.target.classList.contains('modal')) {
    event.target.classList.remove('active');
  }
});

// Data Functions
function viewReport(studentId) {
  showSection('reports');
  // In a real app, this would load the specific student's report
  console.log('Viewing report for student:', studentId);
}

function viewSubmissions(assignmentId) {
  showSection('submissions');
  console.log('Viewing submissions for assignment:', assignmentId);
}

function exportData() {
  // CSV Export functionality
  console.log('Exporting data...');
  alert('Export feature coming soon!');
}

function generateReport() {
  // Generate new report
  console.log('Generating report...');
}

function reviewReport() {
  alert('Report marked as reviewed');
}

function dismissReport() {
  alert('Report dismissed');
}

function contactStudent() {
  alert('Contacting student...');
}

function expandText(textType) {
  alert(`Expanded ${textType} text`);
}

function importStudents() {
  alert('Import functionality coming soon!');
}

// Theme Toggle
function setupThemeToggle() {
  const themeToggle = document.getElementById('themeToggle');
  const currentTheme = localStorage.getItem('theme') || 'light';
  
  document.documentElement.setAttribute('data-theme', currentTheme);
  
  if (currentTheme === 'dark') {
    themeToggle.querySelector('i').classList.replace('fa-moon', 'fa-sun');
  }
  
  themeToggle.addEventListener('click', function() {
    const html = document.documentElement;
    const newTheme = html.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
    
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    const icon = this.querySelector('i');
    if (newTheme === 'dark') {
      icon.classList.replace('fa-moon', 'fa-sun');
    } else {
      icon.classList.replace('fa-sun', 'fa-moon');
    }
  });
}

// Logout
document.addEventListener('click', function(e) {
  if (e.target.closest('a[href="#logout"]')) {
    e.preventDefault();
    logout();
  }
});

function logout() {
  localStorage.removeItem('authToken');
  localStorage.removeItem('userRole');
  localStorage.removeItem('userName');
  window.location.href = 'login.html';
}

// API Helper Functions
async function apiCall(endpoint, method = 'GET', data = null) {
  const token = localStorage.getItem('authToken');
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };

  if (data && method !== 'GET') {
    options.body = JSON.stringify(data);
  }

  try {
    const response = await fetch(`/api${endpoint}`, options);
    
    if (response.status === 401) {
      logout();
      return null;
    }

    return await response.json();
  } catch (error) {
    console.error('API error:', error);
    return null;
  }
}

// Dropdown menu toggle
document.addEventListener('click', function(e) {
  const dropdownBtn = e.target.closest('.dropdown-btn');
  if (dropdownBtn) {
    const dropdown = dropdownBtn.closest('.nav-dropdown');
    const menu = dropdown.querySelector('.dropdown-menu');
    menu.classList.toggle('active');
  } else if (!e.target.closest('.nav-dropdown')) {
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
      menu.classList.remove('active');
    });
  }
});

// Search functionality
document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.querySelector('.navbar-search input');
  if (searchInput) {
    searchInput.addEventListener('input', function(e) {
      const term = e.target.value.toLowerCase();
      if (term.length > 0) {
        performSearch(term);
      }
    });
  }
});

function performSearch(term) {
  console.log('Searching for:', term);
  // Implement search functionality
}

// Table row click handling
document.addEventListener('click', function(e) {
  const tableRow = e.target.closest('.data-table tbody tr');
  if (tableRow && !e.target.closest('button')) {
    console.log('Row clicked:', tableRow);
  }
});

// Print functionality
window.printReport = function() {
  window.print();
};