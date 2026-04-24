/*
 * Assignments Routes
 */

const express = require('express');
const router = express.Router();
const { Assignment, Submission } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');

// Create Assignment (Faculty/Admin)
router.post('/', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const { title, description, courseId, dueDate, maxMarks } = req.body;

    const assignment = new Assignment({
      title,
      description,
      courseId,
      dueDate,
      maxMarks,
      createdBy: req.user.userId
    });

    await assignment.save();

    res.status(201).json({
      success: true,
      message: 'Assignment created successfully',
      assignment
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Course Assignments
router.get('/course/:courseId', authenticate, async (req, res) => {
  try {
    const assignments = await Assignment.find({ courseId: req.params.courseId })
      .populate('createdBy', 'fullName')
      .sort({ dueDate: 1 });

    res.json({
      success: true,
      assignments
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Assignment Details
router.get('/:assignmentId', authenticate, async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.assignmentId)
      .populate('createdBy', 'fullName');

    if (!assignment) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    const submissionCount = await Submission.countDocuments({ assignmentId: assignment._id });

    res.json({
      success: true,
      assignment,
      submissionCount
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Update Assignment (Faculty/Admin)
router.put('/:assignmentId', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const assignment = await Assignment.findByIdAndUpdate(
      req.params.assignmentId,
      req.body,
      { new: true }
    );

    res.json({
      success: true,
      message: 'Assignment updated successfully',
      assignment
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Delete Assignment (Faculty/Admin)
router.delete('/:assignmentId', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    await Assignment.deleteOne({ _id: req.params.assignmentId });
    
    // Delete related submissions
    await Submission.deleteMany({ assignmentId: req.params.assignmentId });

    res.json({
      success: true,
      message: 'Assignment deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
