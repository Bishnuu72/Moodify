const mongoose = require('mongoose');
require('dotenv').config();

console.log('Testing MongoDB Connection...\n');

mongoose.connect(process.env.MONGODB_URI, {
  dbName: process.env.DB_NAME,
})
.then(() => {
  console.log('✅ MongoDB Connected Successfully!');
  console.log(`📊 Database: ${process.env.DB_NAME}`);
  console.log(`🌐 Host: ${mongoose.connection.host}`);
  
  // Test creating a document
  const MoodEntry = require('./models/MoodEntry');
  
  return MoodEntry.create({
    userId: 'test_user_' + Date.now(),
    mood: 'Happy',
    emotionScore: 8,
    note: 'Testing MongoDB connection!',
    tags: ['test'],
  });
})
.then((mood) => {
  console.log('\n✅ Test Document Created:');
  console.log(JSON.stringify(mood.toObject(), null, 2));
  
  // Clean up test data
  return mood.deleteOne();
})
.then(() => {
  console.log('\n✅ Test completed successfully!');
  console.log('Your MongoDB is working perfectly! 🎉\n');
  process.exit(0);
})
.catch((err) => {
  console.error('\n❌ Error:', err.message);
  console.error('\nPlease check:\n1. MongoDB URI in .env file\n2. Internet connection\n3. MongoDB Atlas IP whitelist\n');
  process.exit(1);
});
