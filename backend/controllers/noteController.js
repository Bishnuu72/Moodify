const PatientNote = require('../models/PatientNote');

// @desc    Create or update patient note
// @route   POST /api/notes
// @access  Private (Therapists only)
const createOrUpdateNote = async (req, res) => {
  try {
    console.log('📝 [SAVE NOTE] Request received:', req.body);
    
    const { therapistId, patientId, patientName, note } = req.body;

    // Validate required fields
    if (!therapistId || !patientId || !note) {
      console.log('❌ [SAVE NOTE] Validation failed - missing fields');
      return res.status(400).json({
        success: false,
        message: 'Therapist ID, patient ID, and note are required',
      });
    }

    // Check if note already exists for this patient
    const existingNote = await PatientNote.findOne({
      therapistId,
      patientId,
    }).sort({ updatedAt: -1 });

    if (existingNote) {
      // Update existing note
      existingNote.note = note;
      existingNote.updatedAt = new Date();
      await existingNote.save();

      console.log(`✅ [SAVE NOTE] Note updated for patient ${patientName}`);

      return res.json({
        success: true,
        message: 'Note updated successfully',
        data: existingNote,
      });
    }

    // Create new note
    const patientNote = await PatientNote.create({
      therapistId,
      patientId,
      patientName,
      note,
    });

    console.log(`✅ [SAVE NOTE] Note created for patient ${patientName}`);

    res.status(201).json({
      success: true,
      message: 'Note created successfully',
      data: patientNote,
    });
  } catch (error) {
    console.error('❌ [SAVE NOTE] Error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error saving note',
      error: error.message,
    });
  }
};

// @desc    Get notes for a specific patient
// @route   GET /api/notes/patient/:patientId?therapistId=:therapistId
// @access  Private
const getPatientNotes = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { therapistId } = req.query;

    if (!therapistId) {
      return res.status(400).json({
        success: false,
        message: 'Therapist ID is required',
      });
    }

    const notes = await PatientNote.find({
      therapistId,
      patientId,
    }).sort({ updatedAt: -1 });

    console.log(`✅ Fetched ${notes.length} notes for patient ${patientId}`);

    res.json({
      success: true,
      count: notes.length,
      data: notes,
    });
  } catch (error) {
    console.error('❌ Error fetching patient notes:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching patient notes',
      error: error.message,
    });
  }
};

// @desc    Get all notes for a therapist
// @route   GET /api/notes/therapist/:therapistId
// @access  Private
const getTherapistNotes = async (req, res) => {
  try {
    const { therapistId } = req.params;

    const notes = await PatientNote.find({ therapistId })
      .sort({ updatedAt: -1 })
      .limit(100);

    console.log(`✅ Fetched ${notes.length} notes for therapist ${therapistId}`);

    res.json({
      success: true,
      count: notes.length,
      data: notes,
    });
  } catch (error) {
    console.error('❌ Error fetching therapist notes:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching therapist notes',
      error: error.message,
    });
  }
};

module.exports = {
  createOrUpdateNote,
  getPatientNotes,
  getTherapistNotes,
};
