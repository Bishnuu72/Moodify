const mongoose = require('mongoose');

const verificationSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  documents: {
    nationalId: {
      type: String,
      required: true,
    },
    plusTwo: {
      type: String,
      default: null,
    },
    undergraduate: {
      type: String,
      default: null,
    },
    postgraduate: {
      type: String,
      default: null,
    },
    phd: {
      type: String,
      default: null,
    },
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending',
    index: true,
  },
  rejectionReason: {
    type: String,
    default: null,
  },
  reviewedBy: {
    type: String,
    default: null,
  },
  reviewedAt: {
    type: Date,
    default: null,
  },
  submittedAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Verification', verificationSchema);
