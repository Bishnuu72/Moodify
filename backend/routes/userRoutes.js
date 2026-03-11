const express = require('express');
const router = express.Router();
const {
  createUser,
  getUserProfile,
  updateUserProfile,
  getAllUsers,
} = require('../controllers/userController');

router.route('/')
  .get(getAllUsers)
  .post(createUser);

router.route('/:userId')
  .get(getUserProfile)
  .put(updateUserProfile);

module.exports = router;
