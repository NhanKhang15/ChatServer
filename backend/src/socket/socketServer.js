const jwt = require('jsonwebtoken');
const env = require('../config/env');
const db = require('../db/Database');

function initializeSocket(io) {
  // Middleware for JWT authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Unauthorized'));
      }

      const decoded = jwt.verify(token, env.JWT_SECRET);
      socket.userId = decoded.userId;
      socket.username = decoded.username;
      next();
    } catch (error) {
      next(new Error('Unauthorized'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`✓ User ${socket.userId} (${socket.username}) connected: ${socket.id}`);

    // Join user-specific room
    socket.join(`user:${socket.userId}`);

    // Handle message:send event
    socket.on('message:send', async (data) => {
      try {
        const { conversationId, type, content, attachment } = data;

        // Validate input
        if (!conversationId || !type) {
          socket.emit('error', 'Missing conversationId or type');
          return;
        }

        // Verify user is part of this conversation
        const [conversation] = await db.query(
          'SELECT id, user_a_id, user_b_id FROM conversations WHERE id = ? AND (user_a_id = ? OR user_b_id = ?)',
          [conversationId, socket.userId, socket.userId]
        );

        if (!conversation) {
          socket.emit('error', 'Unauthorized conversation');
          return;
        }

        // Prepare message data
        const messageData = {
          conversation_id: conversationId,
          sender_id: socket.userId,
          type,
          content: content || null,
          attachment_key: attachment?.key || null,
          attachment_name: attachment?.name || null,
          attachment_size: attachment?.size || null,
          attachment_mime: attachment?.mime || null,
        };

        // Save message to database
        await db.execute(
          `INSERT INTO messages (conversation_id, sender_id, type, content, attachment_key, attachment_name, attachment_size, attachment_mime)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            messageData.conversation_id,
            messageData.sender_id,
            messageData.type,
            messageData.content,
            messageData.attachment_key,
            messageData.attachment_name,
            messageData.attachment_size,
            messageData.attachment_mime,
          ]
        );

        // Get the inserted message
        const [message] = await db.query(
          'SELECT id, conversation_id, sender_id, type, content, attachment_key, attachment_name, attachment_size, attachment_mime, created_at FROM messages WHERE sender_id = ? AND conversation_id = ? ORDER BY id DESC LIMIT 1',
          [socket.userId, conversationId]
        );

        // Emit to both users in conversation
        const otherUserId = conversation.user_a_id === socket.userId ? conversation.user_b_id : conversation.user_a_id;
        io.to(`user:${socket.userId}`).emit('message:new', message);
        io.to(`user:${otherUserId}`).emit('message:new', message);
      } catch (error) {
        console.error('message:send error:', error);
        socket.emit('error', 'Failed to send message');
      }
    });

    // Handle typing event
    socket.on('typing', async (data) => {
      try {
        const { conversationId } = data;
        const [conversation] = await db.query(
          'SELECT id, user_a_id, user_b_id FROM conversations WHERE id = ? AND (user_a_id = ? OR user_b_id = ?)',
          [conversationId, socket.userId, socket.userId]
        );

        if (!conversation) return;

        const otherUserId = conversation.user_a_id === socket.userId ? conversation.user_b_id : conversation.user_a_id;
        io.to(`user:${otherUserId}`).emit('typing', {
          conversationId,
          userId: socket.userId,
          username: socket.username,
        });
      } catch (error) {
        console.error('typing error:', error);
      }
    });

    // Handle message:read event
    socket.on('message:read', async (data) => {
      try {
        const { messageId, conversationId } = data;

        // Update message read_at
        await db.execute(
          'UPDATE messages SET read_at = NOW() WHERE id = ? AND conversation_id = ?',
          [messageId, conversationId]
        );

        // Get the message
        const [message] = await db.query(
          'SELECT id, conversation_id, sender_id FROM messages WHERE id = ?',
          [messageId]
        );

        if (message) {
          io.to(`user:${message.sender_id}`).emit('message:read', { messageId, conversationId });
        }
      } catch (error) {
        console.error('message:read error:', error);
      }
    });

    // Handle disconnect
    socket.on('disconnect', () => {
      console.log(`✓ User ${socket.userId} disconnected`);
    });
  });
}

module.exports = initializeSocket;
