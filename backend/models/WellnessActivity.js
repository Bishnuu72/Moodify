const mongoose = require('mongoose');

const wellnessActivitySchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    enum: ['breathing', 'meditation', 'journaling', 'relaxation'],
    required: true,
    index: true,
  },
  duration: {
    type: Number, // in minutes
    default: 5,
  },
  musicUrl: {
    type: String,
    default: null,
  },
  musicDuration: {
    type: Number, // in seconds
    default: null,
  },
  musicTitle: {
    type: String,
    default: null,
  },
  isMusicOptional: {
    type: Boolean,
    default: false,
  },
  // For journaling questions
  journalQuestion: {
    type: String,
    default: null,
  },
  instructions: {
    type: String,
    default: '',
  },
  difficulty: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner',
  },
  tags: [{
    type: String,
  }],
  isActive: {
    type: Boolean,
    default: true,
  },
  createdBy: {
    type: String, // admin userId
    required: true,
  },
}, {
  timestamps: true,
});

// Index for faster queries
wellnessActivitySchema.index({ category: 1, isActive: 1 });
wellnessActivitySchema.index({ createdBy: 1 });

module.exports = mongoose.model('WellnessActivity', wellnessActivitySchema);
