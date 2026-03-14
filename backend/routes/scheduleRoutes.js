const express = require('express');
const router = express.Router();
const {
  createSchedule,
  getTherapistSchedules,
  getPatientSchedules,
  updateScheduleStatus,
  deleteSchedule,
} = require('../controllers/scheduleController');

// Create a new schedule
router.post('/', createSchedule);

// Get schedules for a therapist
router.get('/therapist/:therapistId', getTherapistSchedules);

// Get schedules for a patient
router.get('/patient/:patientId', getPatientSchedules);

// Update schedule status
router.put('/:id/status', updateScheduleStatus);

// Delete a schedule
router.delete('/:id', deleteSchedule);

module.exports = router;
