/*
 * Plagiarism Detection Utilities
 * Tokenization and similarity calculation
 */

// Tokenize text into words
function tokenize(text) {
  if (!text) return [];
  
  // Remove special characters and convert to lowercase
  return text
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .split(/\s+/)
    .filter(token => token.length > 2); // Remove tokens shorter than 2 chars
}

// Calculate Jaccard Similarity
function calculateJaccardSimilarity(set1, set2) {
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);
  
  return union.size === 0 ? 0 : (intersection.size / union.size) * 100;
}

// Calculate Cosine Similarity
function calculateCosineSimilarity(tokens1, tokens2) {
  const freq1 = getTokenFrequency(tokens1);
  const freq2 = getTokenFrequency(tokens2);
  
  const allTokens = new Set([...Object.keys(freq1), ...Object.keys(freq2)]);
  
  let dotProduct = 0;
  let magnitude1 = 0;
  let magnitude2 = 0;
  
  for (const token of allTokens) {
    const val1 = freq1[token] || 0;
    const val2 = freq2[token] || 0;
    
    dotProduct += val1 * val2;
    magnitude1 += val1 * val1;
    magnitude2 += val2 * val2;
  }
  
  magnitude1 = Math.sqrt(magnitude1);
  magnitude2 = Math.sqrt(magnitude2);
  
  if (magnitude1 === 0 || magnitude2 === 0) return 0;
  
  return (dotProduct / (magnitude1 * magnitude2)) * 100;
}

// Get token frequency
function getTokenFrequency(tokens) {
  return tokens.reduce((freq, token) => {
    freq[token] = (freq[token] || 0) + 1;
    return freq;
  }, {});
}

// Determine risk level based on similarity
function getRiskLevel(similarity) {
  if (similarity < 25) return 'low';
  if (similarity < 50) return 'medium';
  if (similarity < 75) return 'high';
  return 'critical';
}

// Calculate overall similarity
function calculateSimilarity(tokens, similarSubmissions) {
  const threshold = parseInt(process.env.SIMILARITY_THRESHOLD) || 50;
  
  let maxSimilarity = 0;
  const matchedSources = [];
  
  for (const match of similarSubmissions) {
    const similarity = (match.matchCount / tokens.length) * 100;
    
    if (similarity >= parseInt(process.env.MIN_WORD_MATCH) || 5) {
      matchedSources.push({
        source: `Submission ${match._id}`,
        matchPercentage: similarity,
        submissionId: match._id,
        matchedText: tokens.slice(0, 5).join(' ') // Sample
      });
      
      maxSimilarity = Math.max(maxSimilarity, similarity);
    }
  }
  
  return {
    similarityScore: Math.round(maxSimilarity * 10) / 10,
    riskLevel: getRiskLevel(maxSimilarity),
    matchedSources,
    isFlag: maxSimilarity >= threshold
  };
}

// Find plagiarized sections
function findPlagiarizedSections(text1, text2, minWordMatch = 5) {
  const tokens1 = tokenize(text1);
  const tokens2 = tokenize(text2);
  
  const flaggedSections = [];
  
  for (let i = 0; i <= tokens1.length - minWordMatch; i++) {
    const substring = tokens1.slice(i, i + minWordMatch).join(' ');
    const pattern = new RegExp(`\\b${substring}\\b`, 'gi');
    
    if (pattern.test(tokens2.join(' '))) {
      flaggedSections.push({
        startIndex: i,
        endIndex: i + minWordMatch,
        text: substring,
        matchedWith: 'External/Previous Submission'
      });
    }
  }
  
  return flaggedSections;
}

module.exports = {
  tokenize,
  calculateJaccardSimilarity,
  calculateCosineSimilarity,
  getTokenFrequency,
  getRiskLevel,
  calculateSimilarity,
  findPlagiarizedSections
};
