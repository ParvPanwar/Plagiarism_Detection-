#!/usr/bin/env node

/**
 * Database Seeding Script
 * Populates the database with sample data for testing
 */

const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const models = require('../models');
const { User, Course, Assignment, Submission } = models;

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/plagiarism_detection';

// Sample data
const sampleUsers = [
  {
    fullName: 'Admin User',
    email: 'admin@example.com',
    password: 'AdminPass123',
    userRole: 'admin',
    employeeId: 'EMP001'
  },
  {
    fullName: 'Dr. Jane Smith',
    email: 'jane.smith@university.edu',
    password: 'Faculty123',
    userRole: 'faculty',
    employeeId: 'EMP002'
  },
  {
    fullName: 'Prof. John Wilson',
    email: 'john.wilson@university.edu',
    password: 'Faculty123',
    userRole: 'faculty',
    employeeId: 'EMP003'
  },
  {
    fullName: 'Alice Johnson',
    email: 'alice.johnson@student.edu',
    password: 'Student123',
    userRole: 'student',
    rollNo: '2021001'
  },
  {
    fullName: 'Bob Brown',
    email: 'bob.brown@student.edu',
    password: 'Student123',
    userRole: 'student',
    rollNo: '2021002'
  },
  {
    fullName: 'Carol Davis',
    email: 'carol.davis@student.edu',
    password: 'Student123',
    userRole: 'student',
    rollNo: '2021003'
  }
];

async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });

    console.log('✓ Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Course.deleteMany({});
    await Assignment.deleteMany({});
    console.log('✓ Cleared existing data');

    // Create users
    const createdUsers = await User.insertMany(sampleUsers);
    console.log(`✓ Created ${createdUsers.length} users`);

    // Get faculty and student IDs
    const faculty = createdUsers.filter(u => u.userRole === 'faculty');
    const students = createdUsers.filter(u => u.userRole === 'student');

    // Create courses
    const sampleCourses = [
      {
        courseCode: 'CS101',
        courseName: 'Introduction to Computer Science',
        description: 'Basic concepts of computer science and programming',
        credits: 3,
        facultyId: faculty[0]._id,
        semester: '2024-S1',
        students: students.map(s => s._id)
      },
      {
        courseCode: 'CS201',
        courseName: 'Data Structures and Algorithms',
        description: 'Advanced data structures and algorithm design',
        credits: 4,
        facultyId: faculty[0]._id,
        semester: '2024-S1',
        students: students.slice(0, 2).map(s => s._id)
      },
      {
        courseCode: 'EN101',
        courseName: 'English Composition',
        description: 'Academic writing and composition skills',
        credits: 3,
        facultyId: faculty[1]._id,
        semester: '2024-S1',
        students: students.map(s => s._id)
      }
    ];

    const createdCourses = await Course.insertMany(sampleCourses);
    console.log(`✓ Created ${createdCourses.length} courses`);

    // Create assignments
    const sampleAssignments = [
      {
        title: 'Programming Assignment 1',
        description: 'Implement basic sorting algorithms',
        courseId: createdCourses[0]._id,
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        maxMarks: 100,
        similarityThreshold: 25,
        createdBy: faculty[0]._id
      },
      {
        title: 'Research Paper',
        description: 'Write a research paper on any CS topic',
        courseId: createdCourses[0]._id,
        dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        maxMarks: 50,
        similarityThreshold: 20,
        createdBy: faculty[0]._id
      },
      {
        title: 'Essay Assignment',
        description: 'Write a 1000-word essay on literature',
        courseId: createdCourses[2]._id,
        dueDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
        maxMarks: 100,
        similarityThreshold: 15,
        createdBy: faculty[1]._id
      }
    ];

    const createdAssignments = await Assignment.insertMany(sampleAssignments);
    console.log(`✓ Created ${createdAssignments.length} assignments`);

    // Create sample submissions
    const sampleSubmissions = [];
    for (let i = 0; i < 2; i++) {
      for (let j = 0; j < students.length; j++) {
        sampleSubmissions.push({
          assignmentId: createdAssignments[i]._id,
          studentId: students[j]._id,
          courseId: createdAssignments[i].courseId,
          fileName: `submission_${students[j].rollNo}_${i}.txt`,
          rawText: `This is a sample submission from student ${students[j].fullName}. It contains some text that may help with plagiarism detection testing.`,
          status: j % 2 === 0 ? 'completed' : 'analyzing',
          grade: j % 2 === 0 ? Math.floor(Math.random() * 100) : null,
          feedback: j % 2 === 0 ? 'Good work!' : null,
          isLate: false
        });
      }
    }

    const createdSubmissions = await Submission.insertMany(sampleSubmissions);
    console.log(`✓ Created ${createdSubmissions.length} submissions`);

    console.log('\n✅ Database seeding completed successfully!');
    console.log('\nTest Credentials:');
    console.log('Admin: admin@example.com / AdminPass123');
    console.log('Faculty: jane.smith@university.edu / Faculty123');
    console.log('Student: alice.johnson@student.edu / Student123');

    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run seeding
seedDatabase();
