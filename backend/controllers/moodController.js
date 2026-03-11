const MoodEntry = require('../models/MoodEntry');
const User = require('../models/User');

// @desc    Get all mood entries for a user (or all users if userId is 'all')
// @route   GET /api/moods/:userId
// @access  Public
const getUserMoods = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 50, skip = 0 } = req.query;

    // If userId is 'all', fetch from all users
    const query = userId === 'all' ? {} : { userId };

    const moods = await MoodEntry.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await MoodEntry.countDocuments(query);

    res.json({
      success: true,
      count: moods.length,
      total,
      data: moods,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching moods',
      error: error.message,
    });
  }
};

// @desc    Create new mood entry
// @route   POST /api/moods
// @access  Public
const createMood = async (req, res) => {
  try {
    console.log('🔵 Creating mood entry:', req.body);
    
    const { userId, mood, emotionScore, note, tags, imageUrl, weather, location, isAnonymous } = req.body;

    // Validate required fields
    if (!userId || !mood) {
      return res.status(400).json({
        success: false,
        message: 'userId and mood are required',
      });
    }

    // Create mood entry
    const moodEntry = await MoodEntry.create({
      userId,
      mood,
      emotionScore,
      note,
      tags,
      imageUrl,
      weather,
      location,
      isAnonymous: isAnonymous || false,
    });

    console.log('✅ Mood entry created:', moodEntry._id);

    // Update user's mood count (optional - won't fail if user doesn't exist)
    try {
      const userUpdate = await User.findOneAndUpdate(
        { userId },
        { $inc: { moodEntriesCount: 1 } },
        { upsert: false } // Don't create user if doesn't exist
      );
      
      if (userUpdate) {
        console.log('✅ User mood count updated');
      } else {
        console.log('⚠️ User not found, skipping mood count update');
      }
    } catch (userError) {
      console.log('⚠️ Could not update user mood count:', userError.message);
      // Continue anyway - mood entry was created successfully
    }

    res.status(201).json({
      success: true,
      data: moodEntry,
      message: 'Mood entry created successfully',
    });
  } catch (error) {
    console.error('❌ Error creating mood:', error);
    console.error('❌ Error stack:', error.stack);
    
    res.status(500).json({
      success: false,
      message: 'Error creating mood entry: ' + error.message,
      error: error.message,
    });
  }
};

// @desc    Update mood entry
// @route   PUT /api/moods/:id
// @access  Public
const updateMood = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const moodEntry = await MoodEntry.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    );

    if (!moodEntry) {
      return res.status(404).json({
        success: false,
        message: 'Mood entry not found',
      });
    }

    res.json({
      success: true,
      data: moodEntry,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating mood entry',
      error: error.message,
    });
  }
};

// @desc    Delete mood entry
// @route   DELETE /api/moods/:id
// @access  Public
const deleteMood = async (req, res) => {
  try {
    const { id } = req.params;

    const moodEntry = await MoodEntry.findByIdAndDelete(id);

    if (!moodEntry) {
      return res.status(404).json({
        success: false,
        message: 'Mood entry not found',
      });
    }

    // Decrement user's mood count
    await User.findOneAndUpdate(
      { userId: moodEntry.userId },
      { $inc: { moodEntriesCount: -1 } }
    );

    res.json({
      success: true,
      message: 'Mood entry deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting mood entry',
      error: error.message,
    });
  }
};

// @desc    Get mood statistics
// @route   GET /api/moods/stats/:userId
// @access  Public
const getMoodStats = async (req, res) => {
  try {
    const { userId } = req.params;

    // Calculate date range for this week (last 7 days)
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // Total moods this week
    const weeklyMoods = await MoodEntry.countDocuments({
      userId,
      createdAt: { $gte: oneWeekAgo }
    });

    // Average emotion score this week
    const weeklyAvgResult = await MoodEntry.aggregate([
      { $match: { userId, createdAt: { $gte: oneWeekAgo } } },
      { $group: { _id: null, avg: { $avg: '$emotionScore' } } }
    ]);
    const avgEmotionScore = weeklyAvgResult[0]?.avg || 0;

    // Most used emotion (all time)
    const moodDistribution = await MoodEntry.aggregate([
      { $match: { userId } },
      { $group: { _id: '$mood', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 1 }
    ]);
    const mostUsedMood = moodDistribution.length > 0 ? moodDistribution[0]._id : null;

    // Total entries (all time)
    const totalEntries = await MoodEntry.countDocuments({ userId });

    // Longest streak (all time)
    const allUserMoods = await MoodEntry.find({ userId })
      .sort({ createdAt: -1 })
      .select('createdAt');
    
    let longestStreak = 0;
    let currentStreak = 0;
    
    if (allUserMoods.length > 0) {
      // Calculate current streak
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      let currentDate = new Date(allUserMoods[0].createdAt);
      currentDate.setHours(0, 0, 0, 0);
      
      const diffDays = Math.floor((today - currentDate) / (1000 * 60 * 60 * 24));
      
      if (diffDays <= 1) {
        currentStreak = 1;
        for (let i = 1; i < allUserMoods.length; i++) {
          const prevDate = new Date(allUserMoods[i].createdAt);
          prevDate.setHours(0, 0, 0, 0);
          
          const dayDiff = Math.floor((currentDate - prevDate) / (1000 * 60 * 60 * 24));
          
          if (dayDiff === 1) {
            currentStreak++;
            currentDate = prevDate;
          } else if (dayDiff === 0) {
            continue;
          } else {
            break;
          }
        }
      }
      
      // Calculate longest streak
      let tempStreak = 1;
      for (let i = 0; i < allUserMoods.length - 1; i++) {
        const currDate = new Date(allUserMoods[i].createdAt);
        currDate.setHours(0, 0, 0, 0);
        const nextDate = new Date(allUserMoods[i + 1].createdAt);
        nextDate.setHours(0, 0, 0, 0);
        
        const dayDiff = Math.floor((currDate - nextDate) / (1000 * 60 * 60 * 24));
        
        if (dayDiff === 1) {
          tempStreak++;
        } else if (dayDiff === 0) {
          continue;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      // Check last streak
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    res.json({
      success: true,
      data: {
        weeklyEntries: weeklyMoods,
        avgEmotionScore: parseFloat(avgEmotionScore.toFixed(1)),
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalEntries: totalEntries,
        mostUsedMood: mostUsedMood,
      },
    });
  } catch (error) {
    console.error('❌ Error fetching stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching statistics',
      error: error.message,
    });
  }
};

module.exports = {
  getUserMoods,
  createMood,
  updateMood,
  deleteMood,
  getMoodStats,
};
