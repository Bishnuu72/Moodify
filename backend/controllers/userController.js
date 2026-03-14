const User = require('../models/User');
const PatientRelationship = require('../models/PatientRelationship');
const bcrypt = require('bcryptjs');

// @desc    Register new user (MongoDB only)
// @route   POST /api/users/register
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { email, password, role, displayName } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email',
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate unique userId
    const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Create new user
    const user = await User.create({
      userId,
      email,
      password: hashedPassword, // Store hashed password
      role: role || 'user',
      displayName: displayName || '',
      photoUrl: null,
      bio: null,
      specialization: null,
      experience: null,
      phone: null,
    });

    // Return user data without password (need to explicitly select since schema has select: false)
    const userData = {
      userId: user.userId,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      bio: user.bio,
      specialization: user.specialization,
      experience: user.experience,
      phone: user.phone,
      isVerified: user.isVerified || false,
      verificationStatus: user.verificationStatus,
      verifiedAt: user.verifiedAt,
    };

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: userData,
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Error registering user',
      error: error.message,
    });
  }
};

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    // Find user by email and explicitly select password field
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Check if user is suspended
    if (user.isSuspended) {
      const now = new Date();
      
      // Check if suspension has expired
      if (user.suspendedUntil && now > user.suspendedUntil) {
        // Auto-unsuspend the user
        user.isSuspended = false;
        user.suspendedUntil = null;
        user.suspensionReason = null;
        await user.save();
      } else {
        // User is still suspended
        return res.status(403).json({
          success: false,
          message: 'Account suspended',
          data: {
            reason: user.suspensionReason,
            until: user.suspendedUntil,
          },
        });
      }
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Return user data without password
    const userData = {
      userId: user.userId,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      bio: user.bio,
      specialization: user.specialization,
      experience: user.experience,
      phone: user.phone,
      isVerified: user.isVerified || false,
      verificationStatus: user.verificationStatus,
      verifiedAt: user.verifiedAt,
    };

    res.json({
      success: true,
      message: 'Login successful',
      data: userData,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Error logging in',
      error: error.message,
    });
  }
};

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

    const user = await User.findOne({ userId }).select('+isVerified +verificationStatus +verifiedAt');

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

// @desc    Delete user (Admin only)
// @route   DELETE /api/users/:userId
// @access  Private/Admin
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findOneAndDelete({ userId });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      message: 'User deleted successfully',
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting user',
      error: error.message,
    });
  }
};

// @desc    Suspend user (Admin only)
// @route   PUT /api/users/:userId/suspend
// @access  Private/Admin
const suspendUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { suspendedUntil, reason } = req.body;

    const user = await User.findOneAndUpdate(
      { userId },
      {
        isSuspended: true,
        suspendedUntil: suspendedUntil || null,
        suspensionReason: reason || null,
      },
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
      message: 'User suspended successfully',
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error suspending user',
      error: error.message,
    });
  }
};

// @desc    Unsuspend user (Admin only)
// @route   PUT /api/users/:userId/unsuspend
// @access  Private/Admin
const unsuspendUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findOneAndUpdate(
      { userId },
      {
        isSuspended: false,
        suspendedUntil: null,
        suspensionReason: null,
      },
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
      message: 'User unsuspended successfully',
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error unsuspending user',
      error: error.message,
    });
  }
};

// @desc    Declare a user as my patient (for therapists)
// @route   POST /api/users/declare-patient
// @access  Private (Therapists only)
const declarePatient = async (req, res) => {
  try {
    const { userId } = req.body;
    const { therapistId } = req.body; // In real app, get from auth middleware

    if (!userId || !therapistId) {
      return res.status(400).json({
        success: false,
        message: 'User ID and therapist ID are required',
      });
    }

    // Find the user to verify they exist
    const userToDeclare = await User.findOne({ userId });
    
    if (!userToDeclare) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Check if relationship already exists
    const existingRelationship = await PatientRelationship.findOne({
      therapistId,
      patientId: userId,
    });

    if (existingRelationship) {
      return res.status(400).json({
        success: false,
        message: 'User is already your patient',
      });
    }

    // Create new patient relationship
    const relationship = await PatientRelationship.create({
      therapistId,
      patientId: userId,
      status: 'active',
    });

    console.log(`✅ Patient declared: ${userId} by therapist ${therapistId}`);

    res.status(201).json({
      success: true,
      message: 'User declared as patient successfully',
      data: {
        userId: userToDeclare.userId,
        displayName: userToDeclare.displayName,
        email: userToDeclare.email,
        role: userToDeclare.role,
        declaredAt: relationship.declaredAt,
      },
    });
  } catch (error) {
    console.error('❌ Error declaring patient:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error declaring patient',
      error: error.message,
    });
  }
};

// @desc    Get therapist's patients
// @route   GET /api/users/patients/:therapistId
// @access  Private (Therapists only)
const getTherapistPatients = async (req, res) => {
  try {
    const { therapistId } = req.params;

    // Find all patient relationships for this therapist
    const relationships = await PatientRelationship.find({
      therapistId,
      status: 'active',
    }).sort({ declaredAt: -1 });

    // Get patient details
    const patients = await Promise.all(
      relationships.map(async (rel) => {
        const patient = await User.findOne({ userId: rel.patientId }).select('-password');
        if (patient) {
          return {
            userId: patient.userId,
            displayName: patient.displayName,
            email: patient.email,
            photoUrl: patient.photoUrl,
            role: patient.role,
            declaredAt: rel.declaredAt,
            status: rel.status,
          };
        }
        return null;
      })
    );

    // Filter out null values
    const validPatients = patients.filter(p => p !== null);

    console.log(`✅ Fetched ${validPatients.length} patients for therapist ${therapistId}`);

    res.json({
      success: true,
      count: validPatients.length,
      data: validPatients,
    });
  } catch (error) {
    console.error('❌ Error fetching patients:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching patients',
      error: error.message,
    });
  }
};

module.exports = {
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
};
