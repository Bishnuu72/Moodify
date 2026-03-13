const express = require('express');
const router = express.Router();
const {
  getWellnessActivities,
  getWellnessActivity,
  createWellnessActivity,
  updateWellnessActivity,
  deleteWellnessActivity,
  getAdminWellnessActivities,
} = require('../controllers/wellnessController');

// Public routes (for users)
router.route('/')
  .get(getWellnessActivities);

router.route('/:id')
  .get(getWellnessActivity);

// Admin routes
router.route('/admin/create')
  .post(createWellnessActivity);

router.route('/admin/:adminId')
  .get(getAdminWellnessActivities);

router.route('/admin/:id')
  .put(updateWellnessActivity)
  .delete(deleteWellnessActivity);

module.exports = router;
