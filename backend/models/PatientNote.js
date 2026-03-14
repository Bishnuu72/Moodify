const mongoose = require('mongoose');

const patientNoteSchema = new mongoose.Schema({
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
  note: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for faster queries
patientNoteSchema.index({ therapistId: 1, patientId: 1, createdAt: -1 });

module.exports = mongoose.model('PatientNote', patientNoteSchema);
