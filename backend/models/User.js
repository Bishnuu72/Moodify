const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    index: true,
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'therapist'],
    default: 'user',
    index: true,
  },
  displayName: {
    type: String,
    default: '',
  },
  photoUrl: {
    type: String,
    default: null,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false, // Don't return by default in queries
  },
  bio: {
    type: String,
    default: null,
  },
  specialization: {
    type: String,
    default: null,
  },
  experience: {
    type: Number,
    default: null,
  },
  phone: {
    type: String,
    default: null,
  },
  // Additional fields for mood tracking
  preferredMood: {
    type: String,
    default: '',
  },
  interests: [{
    type: String,
  }],
  moodEntriesCount: {
    type: Number,
    default: 0,
  },
  // Suspension fields
  isSuspended: {
    type: Boolean,
    default: false,
  },
  suspendedUntil: {
    type: Date,
    default: null,
  },
  suspensionReason: {
    type: String,
    default: null,
  },
  // Verification fields for therapist account
  isVerified: {
    type: Boolean,
    default: false,
  },
  verificationStatus: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: null,
  },
  verifiedAt: {
    type: Date,
    default: null,
  },
}, {
  timestamps: true, // Automatically adds createdAt and updatedAt
});

// Index for faster queries
userSchema.index({ email: 1 });
userSchema.index({ userId: 1 });
userSchema.index({ role: 1 });

module.exports = mongoose.model('User', userSchema);
