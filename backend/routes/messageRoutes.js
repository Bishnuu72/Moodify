const express = require('express');
const router = express.Router();
const {
  sendMessage,
  getMessages,
  getConversations,
  markAsRead,
} = require('../controllers/messageController');

// Send message (POST /api/messages/send)
router.post('/send', sendMessage);

// Get conversations for a user (GET /api/messages/conversations/:userId)
// MUST be before /:userId1/:userId2 to avoid route conflict!
router.get('/conversations/:userId', getConversations);

// Get messages between two users (GET /api/messages/:userId1/:userId2)
router.get('/:userId1/:userId2', getMessages);

// Mark messages as read (PUT /api/messages/read)
router.put('/read', markAsRead);

module.exports = router;
