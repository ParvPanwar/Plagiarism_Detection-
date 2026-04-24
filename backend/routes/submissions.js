/*
 * Submissions Routes
 * Handle file uploads and submission management
 */

const express = require('express');
const router = express.Router();
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const { Submission, Assignment, Report } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');
const { analyzeSubmission } = require('../services/plagiarismService');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = process.env.UPLOAD_DIR || './uploads';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 },
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  }
});

// Submit Assignment
router.post('/', authenticate, upload.single('file'), async (req, res) => {
  try {
    const { assignmentId, text } = req.body;
    const studentId = req.user.userId;

    if (!assignmentId && !text && !req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please provide assignment content'
      });
    }

    // Find assignment
    const assignment = await Assignment.findById(assignmentId);
    if (!assignment) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    // Create submission
    const submission = new Submission({
      assignmentId,
      studentId,
      courseId: assignment.courseId,
      fileUrl: req.file ? `/uploads/${req.file.filename}` : null,
      fileName: req.file ? req.file.originalname : 'text-submission',
      fileSize: req.file ? req.file.size : 0,
      mimeType: req.file ? req.file.mimetype : 'text/plain',
      rawText: text || '',
      status: 'analyzing'
    });

    await submission.save();

    // Start plagiarism analysis async
    analyzeSubmission(submission._id).catch(err => console.error('Analysis error:', err));

    res.status(201).json({
      success: true,
      message: 'Submission received and queued for analysis',
      submission: {
        id: submission._id,
        status: submission.status,
        submissionDate: submission.submissionDate
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Student Submissions
router.get('/student', authenticate, authorize(['student']), async (req, res) => {
  try {
    const submissions = await Submission.find({ studentId: req.user.userId })
      .populate('assignmentId', 'title dueDate')
      .sort({ submissionDate: -1 });

    res.json({
      success: true,
      submissions
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Course Submissions (Faculty)
router.get('/course/:courseId', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const { courseId } = req.params;
    const { status, page = 1, limit = 20 } = req.query;

    let query = { courseId };
    if (status) query.status = status;

    const submissions = await Submission.find(query)
      .populate('studentId', 'fullName email')
      .populate('assignmentId', 'title dueDate')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ submissionDate: -1 });

    const total = await Submission.countDocuments(query);

    res.json({
      success: true,
      submissions,
      pagination: {
        total,
        pages: Math.ceil(total / limit),
        currentPage: page
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Submission Details
router.get('/:submissionId', authenticate, async (req, res) => {
  try {
    const submission = await Submission.findById(req.params.submissionId)
      .populate('studentId', 'fullName email')
      .populate('assignmentId');

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    // Get plagiarism report
    const report = await Report.findOne({ submissionId: submission._id });

    res.json({
      success: true,
      submission,
      report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Grade Submission (Faculty)
router.put('/:submissionId/grade', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const { submissionId } = req.params;
    const { grade, feedback } = req.body;

    if (grade < 0 || grade > 100) {
      return res.status(400).json({
        success: false,
        message: 'Grade must be between 0 and 100'
      });
    }

    const submission = await Submission.findByIdAndUpdate(
      submissionId,
      { grade, feedback },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Submission graded successfully',
      submission
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Delete Submission (Student/Admin)
router.delete('/:submissionId', authenticate, async (req, res) => {
  try {
    const submission = await Submission.findById(req.params.submissionId);

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    // Check authorization
    if (req.user.userRole === 'student' && submission.studentId.toString() !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    // Delete file if exists
    if (submission.fileUrl) {
      const filePath = path.join(__dirname, '..', submission.fileUrl);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    await Submission.deleteOne({ _id: submission._id });
    await Report.deleteOne({ submissionId: submission._id });

    res.json({
      success: true,
      message: 'Submission deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
