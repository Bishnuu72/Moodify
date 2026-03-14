const mongoose = require('mongoose');

const patientRelationshipSchema = new mongoose.Schema({
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
  declaredAt: {
    type: Date,
    default: Date.now,
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'archived'],
    default: 'active',
  },
  notes: {
    type: String,
    default: '',
  },
}, {
  timestamps: true,
});

// Compound index to prevent duplicate relationships
patientRelationshipSchema.index({ therapistId: 1, patientId: 1 }, { unique: true });

module.exports = mongoose.model('PatientRelationship', patientRelationshipSchema);
