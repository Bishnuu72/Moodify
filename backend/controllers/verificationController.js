const Verification = require('../models/Verification');
const User = require('../models/User');
const Notification = require('../models/Notification');

// @desc    Submit therapist verification
// @route   POST /api/verification/submit
// @access  Public (therapist can submit)
exports.submitVerification = async (req, res) => {
  try {
    const { userId, documents } = req.body;

    // Validate required fields
    if (!userId || !documents) {
      return res.status(400).json({
        success: false,
        message: 'User ID and documents are required',
      });
    }

    if (!documents.nationalId) {
      return res.status(400).json({
        success: false,
        message: 'National ID is required',
      });
    }

    // Check if verification already exists
    const existingVerification = await Verification.findOne({ userId });
    if (existingVerification) {
      // Allow re-submission if rejected
      if (existingVerification.status === 'rejected') {
        // Update the existing rejected verification with new documents
        existingVerification.documents = {
          nationalId: documents.nationalId,
          plusTwo: documents.plusTwo || null,
          undergraduate: documents.undergraduate || null,
          postgraduate: documents.postgraduate || null,
          phd: documents.phd || null,
        };
        existingVerification.status = 'pending';
        existingVerification.rejectionReason = null;
        existingVerification.submittedAt = new Date();
        await existingVerification.save();
        
        console.log(`✅ Verification re-submitted for user: ${userId} (was rejected, now pending)`);
        
        return res.status(200).json({
          success: true,
          message: 'Verification re-submitted successfully',
          data: existingVerification,
        });
      }
      
      // Block if already pending or approved
      return res.status(400).json({
        success: false,
        message: 'Verification already submitted. Please wait for admin review.',
      });
    }

    // Create new verification
    const verification = await Verification.create({
      userId,
      documents: {
        nationalId: documents.nationalId,
        plusTwo: documents.plusTwo || null,
        undergraduate: documents.undergraduate || null,
        postgraduate: documents.postgraduate || null,
        phd: documents.phd || null,
      },
      status: 'pending',
      submittedAt: new Date(),
    });

    console.log(`✅ Verification submitted for user: ${userId}`);

    res.status(201).json({
      success: true,
      data: verification,
    });
  } catch (error) {
    console.error('❌ Error submitting verification:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error submitting verification',
      error: error.message,
    });
  }
};

// @desc    Get pending verifications (for admin)
// @route   GET /api/verification/pending
// @access  Admin only
exports.getPendingVerifications = async (req, res) => {
  try {
    const verifications = await Verification.find({ status: 'pending' }).sort({ submittedAt: -1 });

    // Manually fetch user details for each verification
    const formattedVerifications = await Promise.all(
      verifications.map(async (verification) => {
        const User = require('mongoose').model('User');
        const user = await User.findOne({ userId: verification.userId });
        
        return {
          userId: verification.userId,
          displayName: user ? user.displayName : 'Unknown',
          specialization: user ? user.specialization : 'Therapist',
          email: user ? user.email : '',
          photoUrl: user ? user.photoUrl : '',
          documents: verification.documents,
          submittedAt: verification.submittedAt,
        };
      })
    );

    console.log(`✅ Found ${formattedVerifications.length} pending verifications`);

    res.json({
      success: true,
      count: formattedVerifications.length,
      data: formattedVerifications,
    });
  } catch (error) {
    console.error('❌ Error fetching pending verifications:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching pending verifications',
      error: error.message,
    });
  }
};

// @desc    Review verification (approve/reject)
// @route   PUT /api/verification/review
// @access  Admin only
exports.reviewVerification = async (req, res) => {
  try {
    const { userId, approved, rejectionReason, adminId } = req.body;

    if (!userId || approved === undefined) {
      return res.status(400).json({
        success: false,
        message: 'User ID and approval status are required',
      });
    }

    // Find verification
    const verification = await Verification.findOne({ userId });
    if (!verification) {
      return res.status(404).json({
        success: false,
        message: 'Verification not found',
      });
    }

    // Update verification status
    verification.status = approved ? 'approved' : 'rejected';
    verification.rejectionReason = approved ? null : rejectionReason;
    verification.reviewedBy = adminId || 'admin';
    verification.reviewedAt = new Date();
    await verification.save();

    // Update user profile
    await User.updateOne(
      { userId },
      { 
        isVerified: approved,
        verificationStatus: approved ? 'verified' : 'rejected',
        verifiedAt: approved ? new Date() : null,
      }
    );

    // Create notification for the therapist
    if (verification.userId) {
      await Notification.create({
        userId: verification.userId,
        title: approved ? '✓ Verification Approved!' : '✗ Verification Rejected',
        message: approved 
          ? `Congratulations! Your therapist account has been verified. You can now access all verified therapist features.`
          : `Your verification application was rejected. Reason: ${rejectionReason}. Please upload clearer documents and reapply.`,
        type: 'verification',
        isRead: false,
        createdAt: new Date(),
      });
    }

    console.log(`✅ Verification ${approved ? 'approved' : 'rejected'} for user: ${userId}`);

    res.json({
      success: true,
      message: approved ? 'Verification approved successfully' : 'Verification rejected',
      data: verification,
    });
  } catch (error) {
    console.error('❌ Error reviewing verification:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error reviewing verification',
      error: error.message,
    });
  }
};

// @desc    Get verification status for a user
// @route   GET /api/verification/status/:userId
// @access  Public
exports.getVerificationStatus = async (req, res) => {
  try {
    const { userId } = req.params;

    const verification = await Verification.findOne({ userId });

    if (!verification) {
      return res.json({
        success: true,
        data: null,
        message: 'No verification submitted',
      });
    }

    res.json({
      success: true,
      data: verification,
    });
  } catch (error) {
    console.error('❌ Error fetching verification status:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching verification status',
      error: error.message,
    });
  }
};
