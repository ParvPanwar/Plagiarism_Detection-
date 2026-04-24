/*
 * Plagiarism Analysis Service
 * Core plagiarism detection algorithm
 */

const { Submission, Report, Token } = require('../models');
const { tokenize, calculateSimilarity } = require('../utils/plagiarismUtils');

// Main analysis function
async function analyzeSubmission(submissionId) {
  try {
    const submission = await Submission.findById(submissionId);
    if (!submission) throw new Error('Submission not found');

    // Extract text
    const text = submission.rawText || await extractTextFromFile(submission.fileUrl);
    
    // Tokenize
    const tokens = tokenize(text);
    const wordCount = tokens.length;

    // Store tokens
    await Token.insertMany(
      tokens.map((token, idx) => ({
        submissionId,
        token,
        position: idx
      }))
    );

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
    const fs = require('fs');
    const path = require('path');
    
    const fullPath = path.join(__dirname, '..', filePath);
    
    if (!fs.existsSync(fullPath)) {
      return '';
    }

    if (filePath.endsWith('.txt')) {
      return fs.readFileSync(fullPath, 'utf-8');
    }

    if (filePath.endsWith('.pdf')) {
      // PDF extraction would require pdfparse or similar library
      return '';
    }

    if (filePath.endsWith('.docx')) {
      // DOCX extraction would require docx parser
      return '';
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
