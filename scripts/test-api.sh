#!/bin/bash

# Plagiarism Detection System - API Testing Guide
# Run these commands to test all endpoints

API_URL="http://localhost:5000"
TOKEN=""
STUDENT_TOKEN=""
FACULTY_TOKEN=""
ADMIN_TOKEN=""

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Plagiarism Detection API Test Suite${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Helper function for API calls
test_endpoint() {
  local method=$1
  local url=$2
  local data=$3
  local token=$4
  
  echo -e "${YELLOW}Testing: ${method} ${url}${NC}"
  
  if [ "$method" = "GET" ]; then
    curl -s -X "$method" "${API_URL}${url}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" | jq .
  else
    curl -s -X "$method" "${API_URL}${url}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "$data" | jq .
  fi
  
  echo ""
}

# Health Check
echo -e "${BLUE}>>> Health Check${NC}"
curl -s "${API_URL}/health" | jq .
echo ""

# ===== AUTHENTICATION TESTS =====
echo -e "${BLUE}>>> Authentication Tests${NC}"

# Register Admin
echo -e "${YELLOW}1. Register Admin${NC}"
ADMIN_RESPONSE=$(curl -s -X POST "${API_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Admin User",
    "email": "admin@test.example.com",
    "password": "AdminPass123",
    "userRole": "admin"
  }')
echo "$ADMIN_RESPONSE" | jq .
ADMIN_TOKEN=$(echo "$ADMIN_RESPONSE" | jq -r '.token // empty')
echo ""

# Register Faculty
echo -e "${YELLOW}2. Register Faculty${NC}"
FACULTY_RESPONSE=$(curl -s -X POST "${API_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Dr. Test Faculty",
    "email": "faculty@test.example.com",
    "password": "Faculty123",
    "userRole": "faculty",
    "employeeId": "EMP999"
  }')
echo "$FACULTY_RESPONSE" | jq .
FACULTY_TOKEN=$(echo "$FACULTY_RESPONSE" | jq -r '.token // empty')
echo ""

# Register Student
echo -e "${YELLOW}3. Register Student${NC}"
STUDENT_RESPONSE=$(curl -s -X POST "${API_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test Student",
    "email": "student@test.example.com",
    "password": "Student123",
    "userRole": "student",
    "rollNo": "2025001"
  }')
echo "$STUDENT_RESPONSE" | jq .
STUDENT_TOKEN=$(echo "$STUDENT_RESPONSE" | jq -r '.token // empty')
echo ""

# Login Test
echo -e "${YELLOW}4. Login${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "${API_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.example.com",
    "password": "AdminPass123"
  }')
echo "$LOGIN_RESPONSE" | jq .
TEST_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')
echo ""

# Verify Token
echo -e "${YELLOW}5. Verify Token${NC}"
curl -s -X POST "${API_URL}/api/auth/verify" \
  -H "Authorization: Bearer ${TEST_TOKEN}" \
  -H "Content-Type: application/json" | jq .
echo ""

# ===== USER TESTS =====
echo -e "${BLUE}>>> User Management Tests${NC}"

# Get Profile
echo -e "${YELLOW}1. Get Current User Profile${NC}"
curl -s -X GET "${API_URL}/api/users/me" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" | jq .
echo ""

# Update Profile
echo -e "${YELLOW}2. Update Profile${NC}"
curl -s -X PUT "${API_URL}/api/users/me" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test Student Updated"
  }' | jq .
echo ""

# Get All Users (Admin only)
echo -e "${YELLOW}3. Get All Users (Admin)${NC}"
curl -s -X GET "${API_URL}/api/users?userRole=student" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" | jq .
echo ""

# ===== COURSE TESTS =====
echo -e "${BLUE}>>> Course Management Tests${NC}"

# Create Course
echo -e "${YELLOW}1. Create Course${NC}"
COURSE_RESPONSE=$(curl -s -X POST "${API_URL}/api/courses" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "courseCode": "CS101",
    "courseName": "Introduction to CS",
    "description": "Test course",
    "credits": 3,
    "semester": "2025-S1",
    "facultyId": "'$(curl -s "${API_URL}/api/users?userRole=faculty" -H "Authorization: Bearer ${ADMIN_TOKEN}" | jq -r '.data[0]._id')'"
  }')
echo "$COURSE_RESPONSE" | jq .
COURSE_ID=$(echo "$COURSE_RESPONSE" | jq -r '.data._id // empty')
echo ""

# Get Courses
echo -e "${YELLOW}2. Get All Courses${NC}"
curl -s -X GET "${API_URL}/api/courses" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" | jq .
echo ""

# Enroll in Course
echo -e "${YELLOW}3. Enroll in Course${NC}"
curl -s -X POST "${API_URL}/api/courses/${COURSE_ID}/enroll" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" \
  -H "Content-Type: application/json" | jq .
echo ""

# ===== ASSIGNMENT TESTS =====
echo -e "${BLUE}>>> Assignment Management Tests${NC}"

# Create Assignment
echo -e "${YELLOW}1. Create Assignment${NC}"
ASSIGNMENT_RESPONSE=$(curl -s -X POST "${API_URL}/api/assignments" \
  -H "Authorization: Bearer ${FACULTY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Assignment",
    "description": "Test description",
    "courseId": "'${COURSE_ID}'",
    "dueDate": "'$(date -u -d '+7 days' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+7d +%Y-%m-%dT%H:%M:%SZ)'",
    "maxMarks": 100,
    "similarityThreshold": 25
  }')
echo "$ASSIGNMENT_RESPONSE" | jq .
ASSIGNMENT_ID=$(echo "$ASSIGNMENT_RESPONSE" | jq -r '.data._id // empty')
echo ""

# Get Assignments
echo -e "${YELLOW}2. Get Course Assignments${NC}"
curl -s -X GET "${API_URL}/api/assignments/course/${COURSE_ID}" \
  -H "Authorization: Bearer ${FACULTY_TOKEN}" | jq .
echo ""

# ===== SUBMISSION TESTS =====
echo -e "${BLUE}>>> Submission & File Upload Tests${NC}"

# Create test file
TEST_FILE="/tmp/test_submission.txt"
echo "This is a test submission for plagiarism detection testing." > "$TEST_FILE"

# Submit Assignment
echo -e "${YELLOW}1. Submit Assignment${NC}"
SUBMISSION_RESPONSE=$(curl -s -X POST "${API_URL}/api/submissions" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" \
  -F "assignmentId=${ASSIGNMENT_ID}" \
  -F "file=@${TEST_FILE}")
echo "$SUBMISSION_RESPONSE" | jq .
SUBMISSION_ID=$(echo "$SUBMISSION_RESPONSE" | jq -r '.data._id // empty')
echo ""

# Get Student Submissions
echo -e "${YELLOW}2. Get Student Submissions${NC}"
curl -s -X GET "${API_URL}/api/submissions/student" \
  -H "Authorization: Bearer ${STUDENT_TOKEN}" | jq .
echo ""

# Get Submission Details
if [ ! -z "$SUBMISSION_ID" ]; then
  echo -e "${YELLOW}3. Get Submission Details${NC}"
  curl -s -X GET "${API_URL}/api/submissions/${SUBMISSION_ID}" \
    -H "Authorization: Bearer ${STUDENT_TOKEN}" | jq .
  echo ""
fi

# ===== ANALYSIS TESTS =====
echo -e "${BLUE}>>> Plagiarism Analysis Tests${NC}"

if [ ! -z "$SUBMISSION_ID" ]; then
  # Trigger Analysis
  echo -e "${YELLOW}1. Trigger Plagiarism Analysis${NC}"
  curl -s -X POST "${API_URL}/api/analysis/check" \
    -H "Authorization: Bearer ${STUDENT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"submissionId": "'${SUBMISSION_ID}'"}' | jq .
  echo ""

  # Wait a bit for analysis to process
  echo -e "${YELLOW}Waiting for analysis to process...${NC}"
  sleep 3

  # Check Analysis Status
  echo -e "${YELLOW}2. Check Analysis Status${NC}"
  curl -s -X GET "${API_URL}/api/analysis/${SUBMISSION_ID}/status" \
    -H "Authorization: Bearer ${STUDENT_TOKEN}" | jq .
  echo ""

  # ===== REPORT TESTS =====
  echo -e "${BLUE}>>> Plagiarism Report Tests${NC}"

  # Get Report
  echo -e "${YELLOW}1. Get Plagiarism Report${NC}"
  curl -s -X GET "${API_URL}/api/reports/submission/${SUBMISSION_ID}" \
    -H "Authorization: Bearer ${STUDENT_TOKEN}" | jq .
  echo ""
fi

# Get Course Reports (Faculty)
echo -e "${YELLOW}2. Get Course Reports (Faculty)${NC}"
curl -s -X GET "${API_URL}/api/reports/course/${COURSE_ID}" \
  -H "Authorization: Bearer ${FACULTY_TOKEN}" | jq .
echo ""

# ===== GRADING TESTS =====
if [ ! -z "$SUBMISSION_ID" ]; then
  echo -e "${BLUE}>>> Grading Tests${NC}"

  echo -e "${YELLOW}1. Grade Submission (Faculty)${NC}"
  curl -s -X PUT "${API_URL}/api/submissions/${SUBMISSION_ID}/grade" \
    -H "Authorization: Bearer ${FACULTY_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "grade": 85,
      "feedback": "Great work! Minor plagiarism detected, but within acceptable limits."
    }' | jq .
  echo ""
fi

# ===== CLEANUP =====
echo -e "${BLUE}>>> Cleanup${NC}"
rm -f "$TEST_FILE"
echo -e "${GREEN}Test file cleaned up${NC}"
echo ""

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}API Testing Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "- Admin Token: ${ADMIN_TOKEN:0:20}..."
echo "- Faculty Token: ${FACULTY_TOKEN:0:20}..."
echo "- Student Token: ${STUDENT_TOKEN:0:20}..."
echo ""
echo -e "${YELLOW}Test Credentials:${NC}"
echo "- Admin: admin@test.example.com / AdminPass123"
echo "- Faculty: faculty@test.example.com / Faculty123"
echo "- Student: student@test.example.com / Student123"
