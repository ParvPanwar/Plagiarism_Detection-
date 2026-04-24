/*
 * Plagiarism Analysis Service
 * Core plagiarism detection algorithm
 */

const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const mammoth = require('mammoth');
const { Submission, Report, Token } = require('../models');
const { tokenize, calculateSimilarity } = require('../utils/plagiarismUtils');

// Main analysis function
async function analyzeSubmission(submissionId) {
  try {
    const submission = await Submission.findById(submissionId).select('+rawText');
    if (!submission) throw new Error('Submission not found');

    // Extract text
    const text = submission.rawText || await extractTextFromFile(submission.fileUrl);
    
    // Tokenize
    const tokens = tokenize(text);
    const wordCount = tokens.length;

    // Store tokens
    if (tokens.length > 0) {
      await Token.insertMany(
        tokens.map((token, idx) => ({
          submissionId,
          token,
          position: idx
        }))
      );
    }

    // Find similar submissions
    const similarSubmissions = await findSimilarSubmissions(submissionId, tokens);
    
    // Calculate similarity score
    const { similarityScore, riskLevel, matchedSources } = calculateSimilarity(
      tokens,
      similarSubmissions
    );

    // Create report
    const report = new Report({
      submissionId,
      assignmentId: submission.assignmentId,
      studentId: submission.studentId,
      similarityScore,
      riskLevel,
      matchedSources,
      totalMatches: matchedSources.length,
      uniqueMatches: new Set(matchedSources.map(m => m.source)).size,
      analysisTime: Date.now() - new Date(submission.submissionDate).getTime()
    });

    await report.save();

    // Update submission
    submission.status = 'completed';
    submission.rawText = text;
    submission.wordCount = wordCount;
    submission.tokens = tokens.slice(0, 1000); // Store first 1000 tokens
    await submission.save();

    console.log(`✓ Analysis complete for submission ${submissionId}`);
  } catch (error) {
    console.error(`✗ Analysis error for submission ${submissionId}:`, error);
    
    const submission = await Submission.findById(submissionId);
    if (submission) {
      submission.status = 'failed';
      await submission.save();
    }
  }
}

// Find similar submissions
async function findSimilarSubmissions(submissionId, tokens) {
  try {
    // Get tokens from other submissions in same assignment
    const currentSubmission = await Submission.findById(submissionId);
    if (!currentSubmission || tokens.length === 0) {
      return [];
    }

    const similarTokens = await Token.aggregate([
      {
        $match: {
          submissionId: { $ne: submissionId },
          token: { $in: tokens }
        }
      },
      {
        $group: {
          _id: '$submissionId',
          matchCount: { $sum: 1 }
        }
      },
      {
        $lookup: {
          from: 'submissions',
          localField: '_id',
          foreignField: '_id',
          as: 'submission'
        }
      },
      {
        $unwind: '$submission'
      },
      {
        $match: {
          'submission.assignmentId': currentSubmission.assignmentId
        }
      },
      { $sort: { matchCount: -1 } },
      { $limit: 10 }
    ]);

    return similarTokens;
  } catch (error) {
    console.error('Error finding similar submissions:', error);
    return [];
  }
}

// Extract text from file
async function extractTextFromFile(filePath) {
  try {
    const fullPath = path.join(__dirname, '..', filePath);
    
    if (!fs.existsSync(fullPath)) {
      return '';
    }

    if (filePath.endsWith('.txt')) {
      return fs.readFileSync(fullPath, 'utf-8');
    }

    if (filePath.endsWith('.pdf')) {
      const pdfBuffer = fs.readFileSync(fullPath);
      const pdfContent = await pdfParse(pdfBuffer);
      return pdfContent.text || '';
    }

    if (filePath.endsWith('.docx')) {
      const docxContent = await mammoth.extractRawText({ path: fullPath });
      return docxContent.value || '';
    }

    return '';
  } catch (error) {
    console.error('Error extracting text:', error);
    return '';
  }
}

module.exports = {
  analyzeSubmission,
  findSimilarSubmissions,
  extractTextFromFile
};
