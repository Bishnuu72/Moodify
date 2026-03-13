const WellnessActivity = require('../models/WellnessActivity');

// @desc    Get all wellness activities (for users)
// @route   GET /api/wellness
// @access  Public
const getWellnessActivities = async (req, res) => {
  try {
    const { category, isActive = true } = req.query;
    
    const query = {};
    if (category) {
      query.category = category;
    }
    if (isActive !== 'false') {
      query.isActive = true;
    }

    const activities = await WellnessActivity.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: activities.length,
      data: activities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching wellness activities',
      error: error.message,
    });
  }
};

// @desc    Get single wellness activity
// @route   GET /api/wellness/:id
// @access  Public
const getWellnessActivity = async (req, res) => {
  try {
    const { id } = req.params;

    const activity = await WellnessActivity.findById(id);

    if (!activity) {
      return res.status(404).json({
        success: false,
        message: 'Wellness activity not found',
      });
    }

    res.json({
      success: true,
      data: activity,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching wellness activity',
      error: error.message,
    });
  }
};

// @desc    Create wellness activity (Admin only)
// @route   POST /api/wellness/admin/create
// @access  Private/Admin
const createWellnessActivity = async (req, res) => {
  try {
    const {
      title,
      description,
      category,
      duration,
      musicUrl,
      musicDuration,
      musicTitle,
      isMusicOptional,
      journalQuestion,
      instructions,
      difficulty,
      tags,
      createdBy,
    } = req.body;

    // Validate required fields
    if (!title || !description || !category || !createdBy) {
      return res.status(400).json({
        success: false,
        message: 'Title, description, category, and createdBy are required',
      });
    }

    // Validate category
    const validCategories = ['breathing', 'meditation', 'journaling', 'relaxation'];
    if (!validCategories.includes(category)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid category. Must be breathing, meditation, journaling, or relaxation',
      });
    }

    // For journaling, ensure question is provided
    if (category === 'journaling' && !journalQuestion) {
      return res.status(400).json({
        success: false,
        message: 'Journal question is required for journaling activities',
      });
    }

    const activity = await WellnessActivity.create({
      title,
      description,
      category,
      duration: duration || 5,
      musicUrl: musicUrl || null,
      musicDuration: musicDuration || null,
      musicTitle: musicTitle || null,
      isMusicOptional: isMusicOptional || false,
      journalQuestion: journalQuestion || null,
      instructions: instructions || '',
      difficulty: difficulty || 'beginner',
      tags: tags || [],
      createdBy,
    });

    res.status(201).json({
      success: true,
      message: 'Wellness activity created successfully',
      data: activity,
    });
  } catch (error) {
    console.error('Create wellness activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating wellness activity',
      error: error.message,
    });
  }
};

// @desc    Update wellness activity (Admin only)
// @route   PUT /api/wellness/admin/:id
// @access  Private/Admin
const updateWellnessActivity = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const activity = await WellnessActivity.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    );

    if (!activity) {
      return res.status(404).json({
        success: false,
        message: 'Wellness activity not found',
      });
    }

    res.json({
      success: true,
      message: 'Wellness activity updated successfully',
      data: activity,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating wellness activity',
      error: error.message,
    });
  }
};

// @desc    Delete wellness activity (Admin only)
// @route   DELETE /api/wellness/admin/:id
// @access  Private/Admin
const deleteWellnessActivity = async (req, res) => {
  try {
    const { id } = req.params;

    const activity = await WellnessActivity.findByIdAndDelete(id);

    if (!activity) {
      return res.status(404).json({
        success: false,
        message: 'Wellness activity not found',
      });
    }

    res.json({
      success: true,
      message: 'Wellness activity deleted successfully',
      data: activity,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting wellness activity',
      error: error.message,
    });
  }
};

// @desc    Get admin's wellness activities
// @route   GET /api/wellness/admin/:adminId
// @access  Private/Admin
const getAdminWellnessActivities = async (req, res) => {
  try {
    const { adminId } = req.params;
    const { category } = req.query;

    const query = { createdBy: adminId };
    if (category) {
      query.category = category;
    }

    const activities = await WellnessActivity.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: activities.length,
      data: activities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching admin wellness activities',
      error: error.message,
    });
  }
};

module.exports = {
  getWellnessActivities,
  getWellnessActivity,
  createWellnessActivity,
  updateWellnessActivity,
  deleteWellnessActivity,
  getAdminWellnessActivities,
};
