/*
 * Analysis Routes
 * Plagiarism analysis endpoints
 */

const express = require('express');
const router = express.Router();
const { Submission, Report } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');
const { analyzeSubmission } = require('../services/plagiarismService');

// Trigger Analysis
router.post('/check', authenticate, async (req, res) => {
  try {
    const { submissionId } = req.body;

    const submission = await Submission.findById(submissionId);
    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    // Start analysis
    analyzeSubmission(submissionId).catch(err => console.error(err));

    res.json({
      success: true,
      message: 'Analysis queued',
      submissionId
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get Analysis Status
router.get('/:submissionId/status', authenticate, async (req, res) => {
  try {
    const submission = await Submission.findById(req.params.submissionId);

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    const report = submission.status === 'completed' 
      ? await Report.findOne({ submissionId: submission._id })
      : null;

    res.json({
      success: true,
      submission: {
        id: submission._id,
        status: submission.status,
        submissionDate: submission.submissionDate
      },
      report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Batch Analysis
router.post('/batch', authenticate, authorize(['faculty', 'admin']), async (req, res) => {
  try {
    const { submissionIds } = req.body;

    if (!Array.isArray(submissionIds) || submissionIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid submission IDs'
      });
    }

    // Queue all submissions for analysis
    for (const submissionId of submissionIds) {
      analyzeSubmission(submissionId).catch(err => console.error(err));
    }

    res.json({
      success: true,
      message: `${submissionIds.length} submissions queued for analysis`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
