const mongoose = require('mongoose');
require('dotenv').config();

console.log('🔍 Testing User Registration Flow...\n');

// Test 1: MongoDB Connection
console.log('Test 1: Connecting to MongoDB...');
mongoose.connect(process.env.MONGODB_URI, {
  dbName: process.env.DB_NAME,
})
.then(() => {
  console.log('✅ MongoDB Connected Successfully!\n');
  
  // Test 2: Check if User model works
  console.log('Test 2: Testing User Model...');
  const User = require('./models/User');
  
  return User.countDocuments();
})
.then((count) => {
  console.log(`✅ User model working. Current users in database: ${count}\n`);
  
  // Test 3: Create a test user
  console.log('Test 3: Creating test users (user, therapist, admin)...');
  
  const User = require('./models/User');
  const testUsers = [
    {
      userId: 'test_user_' + Date.now(),
      email: `test.user@test.com`,
      role: 'user',
      displayName: 'Test User',
    },
    {
      userId: 'test_therapist_' + Date.now(),
      email: `test.therapist@test.com`,
      role: 'therapist',
      displayName: 'Test Therapist',
    },
    {
      userId: 'test_admin_' + Date.now(),
      email: `test.admin@test.com`,
      role: 'admin',
      displayName: 'Test Admin',
    },
  ];
  
  return Promise.all(
    testUsers.map(user => 
      User.create(user).then(doc => {
        console.log(`✅ Created: ${doc.role} - ${doc.email}`);
        return doc;
      })
    )
  );
})
.then((createdUsers) => {
  console.log('\n✅ All test users created successfully!\n');
  
  // Test 4: Fetch all users by role
  console.log('Test 4: Fetching users by role...');
  const User = require('./models/User');
  
  return Promise.all([
    User.find({ role: 'user' }).countDocuments(),
    User.find({ role: 'therapist' }).countDocuments(),
    User.find({ role: 'admin' }).countDocuments(),
  ]);
})
.then(([userCount, therapistCount, adminCount]) => {
  console.log(`\n📊 Database Statistics:`);
  console.log(`   Users: ${userCount}`);
  console.log(`   Therapists: ${therapistCount}`);
  console.log(`   Admins: ${adminCount}`);
  console.log(`   Total: ${userCount + therapistCount + adminCount}\n`);
  
  // Clean up test data
  console.log('🧹 Cleaning up test data...');
  const User = require('./models/User');
  return User.deleteMany({
    email: { $in: ['test.user@test.com', 'test.therapist@test.com', 'test.admin@test.com'] }
  });
})
.then((result) => {
  console.log(`✅ Cleaned up ${result.deletedCount} test users\n`);
  
  console.log('🎉 All tests passed! MongoDB is ready for user registration!\n');
  console.log('📝 Next steps:');
  console.log('   1. Start backend: node server.js');
  console.log('   2. Run Flutter app: flutter run');
  console.log('   3. Register a new user in the app');
  console.log('   4. Check console logs to see registration flow\n');
  
  process.exit(0);
})
.catch((err) => {
  console.error('\n❌ Test failed:', err.message);
  console.error('\nPlease check:');
  console.error('1. MongoDB URI in .env file');
  console.error('2. Internet connection');
  console.error('3. MongoDB Atlas IP whitelist settings\n');
  process.exit(1);
});
