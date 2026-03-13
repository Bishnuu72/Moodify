require('dotenv').config();
const mongoose = require('mongoose');
const connectDB = require('./config/database');

// Connect to MongoDB
connectDB();

const User = require('./models/User');

async function updateTherapistVerification() {
  try {
    // Find all therapists and update them as verified
    const result = await User.updateMany(
      { role: 'therapist' },
      { 
        isVerified: true,
        verificationStatus: 'verified',
        verifiedAt: new Date()
      }
    );
    
    console.log(`✅ Updated ${result.modifiedCount} therapist(s) to verified status`);
    
    // Verify the update
    const therapists = await User.find({ role: 'therapist' }).select('userId displayName isVerified verificationStatus verifiedAt');
    console.log('\n📊 Therapist Verification Status:');
    therapists.forEach(t => {
      console.log(`   - ${t.displayName} (${t.userId}): isVerified=${t.isVerified}, status=${t.verificationStatus}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

updateTherapistVerification();
