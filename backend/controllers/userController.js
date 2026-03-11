const User = require('../models/User');

// @desc    Create new user (registration)
// @route   POST /api/users
// @access  Public
const createUser = async (req, res) => {
  try {
    const { userId, email, role, displayName, photoUrl, bio, specialization, experience, phone } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ userId }, { email }] });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists',
      });
    }

    // Create new user
    const user = await User.create({
      userId,
      email,
      role: role || 'user',
      displayName: displayName || '',
      photoUrl: photoUrl || null,
      bio: bio || null,
      specialization: specialization || null,
      experience: experience || null,
      phone: phone || null,
    });

    res.status(201).json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating user',
      error: error.message,
    });
  }
};

// @desc    Get user profile
// @route   GET /api/users/:userId
// @access  Public
const getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findOne({ userId });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching user profile',
      error: error.message,
    });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/:userId
// @access  Public
const updateUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const updates = req.body;

    const user = await User.findOneAndUpdate(
      { userId },
      updates,
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating user profile',
      error: error.message,
    });
  }
};

// @desc    Get all users (Admin only)
// @route   GET /api/users
// @access  Private/Admin
const getAllUsers = async (req, res) => {
  try {
    const { role, limit = 100, skip = 0 } = req.query;

    const query = role ? { role } : {};

    const users = await User.find(query)
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await User.countDocuments(query);

    res.json({
      success: true,
      count: users.length,
      total,
      data: users,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching users',
      error: error.message,
    });
  }
};

module.exports = {
  createUser,
  getUserProfile,
  updateUserProfile,
  getAllUsers,
};
