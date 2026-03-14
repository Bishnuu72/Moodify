const express = require('express');
const router = express.Router();
const {
  createOrUpdateNote,
  getPatientNotes,
  getTherapistNotes,
} = require('../controllers/noteController');

// Debug middleware for notes routes
router.use((req, res, next) => {
  console.log(`📝 [NOTES ROUTE] ${req.method} ${req.path}`);
  next();
});

// Create or update note
router.post('/', createOrUpdateNote);

// Get notes for a specific patient
router.get('/patient/:patientId', getPatientNotes);

// Get all notes for a therapist
router.get('/therapist/:therapistId', getTherapistNotes);

module.exports = router;
