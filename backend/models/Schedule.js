const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
  therapistId: {
    type: String,
    required: true,
    index: true,
  },
  patientId: {
    type: String,
    required: true,
    index: true,
  },
  patientName: {
    type: String,
    required: true,
  },
  patientEmail: {
    type: String,
    required: true,
  },
  patientPhotoUrl: {
    type: String,
    default: null,
  },
  appointmentType: {
    type: String,
    enum: ['voice_call', 'video_call'],
    required: true,
  },
  scheduledDate: {
    type: Date,
    required: true,
  },
  scheduledTime: {
    type: String,
    required: true, // Store as HH:mm format
  },
  duration: {
    type: Number, // in minutes
    default: 30,
  },
  status: {
    type: String,
    enum: ['scheduled', 'confirmed', 'cancelled', 'completed'],
    default: 'scheduled',
  },
  notes: {
    type: String,
    default: '',
  },
  meetingLink: {
    type: String,
    default: null,
  },
}, {
  timestamps: true,
});

// Index for faster queries
scheduleSchema.index({ therapistId: 1, scheduledDate: -1 });
scheduleSchema.index({ patientId: 1, scheduledDate: -1 });

module.exports = mongoose.model('Schedule', scheduleSchema);
