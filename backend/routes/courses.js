/*
 * Courses Routes
 */

const express = require('express');
const router = express.Router();
const { Course, User } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');

// Create Course (Admin)
router.post('/', authenticate, authorize(['admin']), async (req, res) => {
  try {
    const { courseCode, courseName, description, credits, facultyId, semester } = req.body;

    const course = new Course({
      courseCode,
      courseName,
      description,
      credits,
      facultyId,
      semester
    });

    await course.save();

    res.status(201).json({
      success: true,
      message: 'Course created successfully',
      course
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get All Courses
router.get('/', authenticate, async (req, res) => {
  try {
    const courses = await Course.find()
      .populate('facultyId', 'fullName email')
      .sort({ courseCode: 1 });

    res.json({
      success: true,
      courses
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Faculty Courses
router.get('/faculty/my-courses', authenticate, authorize(['faculty']), async (req, res) => {
  try {
    const courses = await Course.find({ facultyId: req.user.userId })
      .sort({ courseCode: 1 });

    res.json({
      success: true,
      courses
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Enroll Student in Course
router.post('/:courseId/enroll', authenticate, authorize(['student']), async (req, res) => {
  try {
    const course = await Course.findById(req.params.courseId);
    
    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found'
      });
    }

    if (course.students.includes(req.user.userId)) {
      return res.status(400).json({
        success: false,
        message: 'Student already enrolled'
      });
    }

    course.students.push(req.user.userId);
    await course.save();

    res.json({
      success: true,
      message: 'Enrolled successfully',
      course
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
