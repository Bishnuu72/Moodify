require('dotenv').config();
const mongoose = require('mongoose');
const Message = require('./models/Message');

async function testMessages() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');
    
    const therapistId = 'user_1773406586445_tip27y8h4';
    const userId = 'user_1773309518115_lg2jdw27p';
    
    console.log(`🔍 Searching messages for therapist: ${therapistId}\n`);
    
    // Try direct query
    const messages = await Message.find({
      $or: [
        { receiverId: therapistId },
        { senderId: therapistId }
      ]
    }).sort({ createdAt: -1 });
    
    console.log(`📊 Found ${messages.length} messages\n`);
    
    if (messages.length > 0) {
      messages.forEach((msg, idx) => {
        console.log(`Message ${idx + 1}:`);
        console.log(`  _id: ${msg._id}`);
        console.log(`  senderId: ${msg.senderId} (type: ${typeof msg.senderId})`);
        console.log(`  receiverId: ${msg.receiverId} (type: ${typeof msg.receiverId})`);
        console.log(`  message: "${msg.message}"`);
        console.log(`  Matches therapist? sender=${msg.senderId === therapistId}, receiver=${msg.receiverId === therapistId}`);
        console.log('');
      });
    } else {
      console.log('❌ NO MESSAGES FOUND!\n');
      console.log('💡 Checking database collection directly...\n');
      
      // Check raw collection
      const db = mongoose.connection.db;
      const messagesCollection = db.collection('messages');
      const allMessages = await messagesCollection.find({}).toArray();
      
      console.log(`Total messages in DB: ${allMessages.length}\n`);
      
      if (allMessages.length > 0) {
        allMessages.forEach((msg, idx) => {
          console.log(`Raw Message ${idx + 1}:`);
          console.log(`  senderId: ${msg.senderId}`);
          console.log(`  receiverId: ${msg.receiverId}`);
          console.log(`  Matches our therapist? sender=${msg.senderId === therapistId}, receiver=${msg.receiverId === therapistId}`);
          console.log('');
        });
      }
    }
    
    await mongoose.disconnect();
    console.log('\n✅ Test completed');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

testMessages();
