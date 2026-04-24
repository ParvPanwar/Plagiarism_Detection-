/*
 * Reports Routes
 * Plagiarism report generation and retrieval
 */

const express = require('express');
const router = express.Router();
const { Report, Submission } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');

// Get Report for Submission
router.get('/submission/:submissionId', authenticate, async (req, res) => {
  try {
    const report = await Report.findOne({ submissionId: req.params.submissionId });

    if (!report) {
      return res.status(404).json({
        success: false,
        message: 'Report not found'
      });
    }

    res.json({
      success: true,
      report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Course Reports (Faculty)
router.get('/course/:courseId', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const reports = await Report.find()
      .where('courseId').equals(req.params.courseId)
      .populate('studentId', 'fullName email')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      reports
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Review Report (Faculty)
router.put('/:reportId/review', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const { reviewNotes, action } = req.body;

    const report = await Report.findByIdAndUpdate(
      req.params.reportId,
      {
        reviewed: true,
        reviewedBy: req.user.userId,
        reviewNotes
      },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Report reviewed successfully',
      report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Flagged Reports
router.get('/', authenticate, async (req, res) => {
  try {
    const { courseId, riskLevel, reviewed, page = 1, limit = 20 } = req.query;

    let query = {};
    if (courseId) query.courseId = courseId;
    if (riskLevel) query.riskLevel = { $in: riskLevel.split(',') };
    if (reviewed !== undefined) query.reviewed = reviewed === 'true';

    const reports = await Report.find(query)
      .populate('studentId', 'fullName email')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await Report.countDocuments(query);

    res.json({
      success: true,
      reports,
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

module.exports = router;
