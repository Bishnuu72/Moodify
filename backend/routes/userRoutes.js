const express = require('express');
const router = express.Router();
const {
  registerUser,
  loginUser,
  createUser,
  getUserProfile,
  updateUserProfile,
  getAllUsers,
  deleteUser,
  suspendUser,
  unsuspendUser,
  declarePatient,
  getTherapistPatients,
} = require('../controllers/userController');

// Registration and Login routes
router.post('/register', registerUser);
router.post('/login', loginUser);

// Declare patient route (for therapists) - MUST be before /:userId to avoid conflicts!
router.post('/declare-patient', declarePatient);

// Get therapist's patients
router.get('/patients/:therapistId', getTherapistPatients);

// Other user routes
router.route('/')
  .get(getAllUsers)
  .post(createUser);

router.route('/:userId')
  .get(getUserProfile)
  .put(updateUserProfile)
  .delete(deleteUser);

// Suspend/Unsuspended routes
router.put('/:userId/suspend', suspendUser);
router.put('/:userId/unsuspend', unsuspendUser);

module.exports = router;
