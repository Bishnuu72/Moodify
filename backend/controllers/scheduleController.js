const Schedule = require('../models/Schedule');

// @desc    Create a new schedule/appointment
// @route   POST /api/schedules
// @access  Private (Therapists only)
const createSchedule = async (req, res) => {
  try {
    const {
      therapistId,
      patientId,
      patientName,
      patientEmail,
      patientPhotoUrl,
      appointmentType,
      scheduledDate,
      scheduledTime,
      duration,
      notes,
    } = req.body;

    // Validate required fields
    if (!therapistId || !patientId || !scheduledDate || !scheduledTime || !appointmentType) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields',
      });
    }

    console.log('📅 [CREATE SCHEDULE] Received date:', scheduledDate);
    console.log('🕐 [CREATE SCHEDULE] Received time:', scheduledTime);

    // Parse the date string (YYYY-MM-DD) and set to midnight UTC
    // This ensures the date stays the same regardless of timezone
    const [year, month, day] = scheduledDate.split('-').map(Number);
    const parsedDate = new Date(Date.UTC(year, month - 1, day));
    
    console.log('📅 [CREATE SCHEDULE] Parsed date (UTC):', parsedDate.toISOString());

    // Check for scheduling conflicts
    const existingSchedule = await Schedule.findOne({
      therapistId,
      scheduledDate: parsedDate,
      scheduledTime: scheduledTime,
      status: { $in: ['scheduled', 'confirmed'] },
    });

    if (existingSchedule) {
      return res.status(409).json({
        success: false,
        message: 'You already have an appointment at this time',
      });
    }

    // Create schedule
    const schedule = await Schedule.create({
      therapistId,
      patientId,
      patientName,
      patientEmail,
      patientPhotoUrl: patientPhotoUrl || null,
      appointmentType,
      scheduledDate: parsedDate,
      scheduledTime,
      duration: duration || 30,
      notes: notes || '',
      status: 'scheduled',
    });

    console.log(`✅ Schedule created: ${schedule._id} for patient ${patientName}`);
    console.log('📅 Stored date:', schedule.scheduledDate.toISOString());

    res.status(201).json({
      success: true,
      message: 'Appointment scheduled successfully',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ Error creating schedule:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error creating schedule',
      error: error.message,
    });
  }
};

// @desc    Get all schedules for a therapist
// @route   GET /api/schedules/therapist/:therapistId
// @access  Private (Therapists only)
const getTherapistSchedules = async (req, res) => {
  try {
    const { therapistId } = req.params;
    const { status, limit = 50, skip = 0 } = req.query;

    const query = { therapistId };
    
    if (status) {
      query.status = status;
    }

    const schedules = await Schedule.find(query)
      .sort({ scheduledDate: -1, scheduledTime: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Schedule.countDocuments(query);

    console.log(`✅ Fetched ${schedules.length} schedules for therapist ${therapistId}`);

    // Format schedules with proper date strings
    const formattedSchedules = schedules.map(schedule => {
      const scheduleObj = schedule.toObject();
      // Add formatted date string for easier frontend use
      const date = new Date(scheduleObj.scheduledDate);
      scheduleObj.formattedDate = `${date.getUTCFullYear()}-${(date.getUTCMonth() + 1).toString().padLeft(2, '0')}-${date.getUTCDate().toString().padLeft(2, '0')}`;
      return scheduleObj;
    });

    res.json({
      success: true,
      count: formattedSchedules.length,
      total,
      data: formattedSchedules,
    });
  } catch (error) {
    console.error('❌ Error fetching schedules:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching schedules',
      error: error.message,
    });
  }
};

// @desc    Get all schedules for a patient
// @route   GET /api/schedules/patient/:patientId
// @access  Private
const getPatientSchedules = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { status, limit = 50, skip = 0 } = req.query;

    const query = { patientId };
    
    if (status) {
      query.status = status;
    }

    const schedules = await Schedule.find(query)
      .sort({ scheduledDate: -1, scheduledTime: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Schedule.countDocuments(query);

    console.log(`✅ Fetched ${schedules.length} schedules for patient ${patientId}`);

    res.json({
      success: true,
      count: schedules.length,
      total,
      data: schedules,
    });
  } catch (error) {
    console.error('❌ Error fetching patient schedules:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching patient schedules',
      error: error.message,
    });
  }
};

// @desc    Update schedule status
// @route   PUT /api/schedules/:id/status
// @access  Private
const updateScheduleStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status || !['scheduled', 'confirmed', 'cancelled', 'completed'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status',
      });
    }

    const schedule = await Schedule.findByIdAndUpdate(
      id,
      { status },
      { new: true, runValidators: true }
    );

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Schedule not found',
      });
    }

    console.log(`✅ Schedule ${id} status updated to ${status}`);

    res.json({
      success: true,
      message: 'Schedule status updated',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ Error updating schedule status:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error updating schedule status',
      error: error.message,
    });
  }
};

// @desc    Delete a schedule
// @route   DELETE /api/schedules/:id
// @access  Private
const deleteSchedule = async (req, res) => {
  try {
    const { id } = req.params;

    const schedule = await Schedule.findByIdAndDelete(id);

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Schedule not found',
      });
    }

    console.log(`✅ Schedule ${id} deleted`);

    res.json({
      success: true,
      message: 'Schedule deleted successfully',
    });
  } catch (error) {
    console.error('❌ Error deleting schedule:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error deleting schedule',
      error: error.message,
    });
  }
};

module.exports = {
  createSchedule,
  getTherapistSchedules,
  getPatientSchedules,
  updateScheduleStatus,
  deleteSchedule,
};
