const mongoose = require('mongoose');

const moodEntrySchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User',
  },
  mood: {
    type: String,
    required: true,
    enum: ['Happy', 'Excited', 'Calm', 'Neutral', 'Tired', 'Sad', 'Anxious', 'Angry', 'Stressed', 'Confused'],
  },
  emotionScore: {
    type: Number,
    min: 0,
    max: 10,
    default: 5,
  },
  note: {
    type: String,
    default: '',
  },
  tags: [{
    type: String,
  }],
  imageUrl: {
    type: String,
    default: null,
  },
  weather: {
    type: String,
    default: null,
  },
  location: {
    type: String,
    default: null,
  },
  isAnonymous: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

moodEntrySchema.index({ userId: 1 });
moodEntrySchema.index({ createdAt: -1 });

module.exports = mongoose.model('MoodEntry', moodEntrySchema);
