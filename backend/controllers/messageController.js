const mongoose = require('mongoose');
const Message = require('../models/Message');

// @desc    Send a message
// @route   POST /api/messages/send
// @access  Public (authenticated users)
exports.sendMessage = async (req, res) => {
  try {
    const { senderId, receiverId, message } = req.body;

    // Validate required fields
    if (!senderId || !receiverId || !message) {
      return res.status(400).json({
        success: false,
        message: 'Sender ID, receiver ID, and message are required',
      });
    }

    // Create and save message
    const newMessage = await Message.create({
      senderId,
      receiverId,
      message,
      isRead: false,
    });

    console.log(`✅ Message sent from ${senderId} to ${receiverId}`);

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: newMessage,
    });
  } catch (error) {
    console.error('❌ Error sending message:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error sending message',
      error: error.message,
    });
  }
};

// @desc    Get messages between two users
// @route   GET /api/messages/:userId1/:userId2
// @access  Public (authenticated users)
exports.getMessages = async (req, res) => {
  try {
    const { userId1, userId2 } = req.params;

    if (!userId1 || !userId2) {
      return res.status(400).json({
        success: false,
        message: 'Both user IDs are required',
      });
    }

    // Fetch messages in both directions
    const messages = await Message.find({
      $or: [
        { senderId: userId1, receiverId: userId2 },
        { senderId: userId2, receiverId: userId1 },
      ],
    }).sort({ createdAt: 1 }); // Oldest first

    console.log(`📊 Found ${messages.length} messages between ${userId1} and ${userId2}`);

    res.json({
      success: true,
      count: messages.length,
      data: messages,
    });
  } catch (error) {
    console.error('❌ Error fetching messages:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching messages',
      error: error.message,
    });
  }
};

// @desc    Get all conversations for a user (therapist dashboard)
// @route   GET /api/messages/conversations/:userId
// @access  Public (authenticated users)
exports.getConversations = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    // Find all messages where user is either sender or receiver
    console.log(`\n🔍 ========== CONVERSATIONS DEBUG ==========`);
    console.log(`🔍 Searching messages for userId: ${userId}`);
    console.log(`🔍 Database name: ${mongoose.connection.db.databaseName}`);
    console.log(`🔍 Collection: messages`);
    console.log(`🔍 Query: { $or: [ { receiverId: "${userId}" }, { senderId: "${userId}" } ] }`);
    
    // First check if collection exists and has any data
    const Message = require('../models/Message');
    const totalMessages = await Message.countDocuments({});
    console.log(`📊 Total messages in entire database: ${totalMessages}`);
    
    if (totalMessages === 0) {
      console.log(`❌ DATABASE IS EMPTY - No messages exist at all!`);
      console.log(`💡 Messages should be created via POST /api/messages/send`);
    }
    
    const messages = await Message.find({
      $or: [
        { receiverId: userId },
        { senderId: userId }
      ]
    })
      .sort({ createdAt: -1 });
    
    console.log(`📬 Found ${messages.length} raw messages in DB`);
    if (messages.length > 0) {
      messages.forEach((msg, idx) => {
        console.log(`  Message ${idx + 1}:`);
        console.log(`    - _id: ${msg._id}`);
        console.log(`    - senderId: ${msg.senderId}`);
        console.log(`    - receiverId: ${msg.receiverId}`);
        console.log(`    - message: ${msg.message}`);
        console.log(`    - matches userId? sender=${msg.senderId === userId}, receiver=${msg.receiverId === userId}`);
      });
    } else {
      console.log(`  ❌ NO MESSAGES FOUND in database for this user!`);
      console.log(`  💡 Try checking if userId format matches:`);
      console.log(`     Looking for: "${userId}"`);
      console.log(`     Type: ${typeof userId}`);
    }
    console.log(`🔍 ========== END DEBUG ==========\n`);

    // Group by the OTHER participant (not the current user)
    const conversationsMap = new Map();
    
    messages.forEach(msg => {
      // Determine the other participant
      const otherUserId = msg.senderId === userId ? msg.receiverId : msg.senderId;
      console.log(`  Processing message: ${msg.senderId} -> ${msg.receiverId}, otherUserId: ${otherUserId}`);
      
      if (!conversationsMap.has(otherUserId)) {
        conversationsMap.set(otherUserId, {
          senderId: otherUserId,
          lastMessage: msg.message,
          timestamp: msg.createdAt,
          isRead: msg.isRead,
          unreadCount: 0,
        });
      }
      
      // Count unread messages (messages received from other user that haven't been read)
      if (!msg.isRead && msg.receiverId === userId) {
        const conv = conversationsMap.get(otherUserId);
        conv.unreadCount += 1;
      }
    });
    
    console.log(`📊 conversationsMap size: ${conversationsMap.size}`);

    const conversations = Array.from(conversationsMap.values());

    // Fetch user details for each conversation
    const User = require('../models/User');
    const enhancedConversations = await Promise.all(
      conversations.map(async (conv) => {
        try {
          const userProfile = await User.findOne({ userId: conv.senderId });
          if (userProfile) {
            return {
              ...conv,
              sender: {
                userId: userProfile.userId,
                displayName: userProfile.displayName,
                photoUrl: userProfile.photoUrl,
                email: userProfile.email,
              }
            };
          }
          return {
            ...conv,
            sender: {
              userId: conv.senderId,
              displayName: 'Unknown User',
              photoUrl: null,
              email: null,
            }
          };
        } catch (error) {
          console.error(`Error fetching user ${conv.senderId}:`, error.message);
          return {
            ...conv,
            sender: {
              userId: conv.senderId,
              displayName: 'Unknown User',
              photoUrl: null,
              email: null,
            }
          };
        }
      })
    );

    console.log(`📊 Found ${enhancedConversations.length} conversations for user ${userId}`);

    res.json({
      success: true,
      count: enhancedConversations.length,
      data: enhancedConversations,
    });
  } catch (error) {
    console.error('❌ Error fetching conversations:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching conversations',
      error: error.message,
    });
  }
};

// @desc    Mark messages as read
// @route   PUT /api/messages/read
// @access  Public (authenticated users)
exports.markAsRead = async (req, res) => {
  try {
    const { senderId, receiverId } = req.body;

    if (!senderId || !receiverId) {
      return res.status(400).json({
        success: false,
        message: 'Sender ID and receiver ID are required',
      });
    }

    // Mark all messages from sender to receiver as read
    const result = await Message.updateMany(
      {
        senderId,
        receiverId,
        isRead: false,
      },
      {
        isRead: true,
        readAt: new Date(),
      }
    );

    console.log(`✅ Marked ${result.modifiedCount} messages as read`);

    res.json({
      success: true,
      message: 'Messages marked as read',
      modifiedCount: result.modifiedCount,
    });
  } catch (error) {
    console.error('❌ Error marking messages as read:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error marking messages as read',
      error: error.message,
    });
  }
};
