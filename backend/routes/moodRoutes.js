const express = require('express');
const router = express.Router();
const {
  getUserMoods,
  createMood,
  updateMood,
  deleteMood,
  getMoodStats,
} = require('../controllers/moodController');

router.route('/:userId')
  .get(getUserMoods);

router.route('/')
  .post(createMood);

router.route('/:id')
  .put(updateMood)
  .delete(deleteMood);

router.route('/stats/:userId')
  .get(getMoodStats);

module.exports = router;
