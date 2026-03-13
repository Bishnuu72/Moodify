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
} = require('../controllers/userController');

// Registration and Login routes
router.post('/register', registerUser);
router.post('/login', loginUser);

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
