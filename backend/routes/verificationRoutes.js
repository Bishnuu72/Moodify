const express = require('express');
const router = express.Router();
const { 
  submitVerification, 
  getPendingVerifications, 
  reviewVerification,
  getVerificationStatus 
} = require('../controllers/verificationController');

// Submit verification (POST /api/verification/submit)
router.post('/submit', submitVerification);

// Get pending verifications (GET /api/verification/pending)
router.get('/pending', getPendingVerifications);

// Review verification (PUT /api/verification/review)
router.put('/review', reviewVerification);

// Get verification status (GET /api/verification/status/:userId)
router.get('/status/:userId', getVerificationStatus);

module.exports = router;
