const db = require('../db/Database');

const createOrGetConversation = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    if (userId === req.userId) {
      return res.status(400).json({ error: 'Cannot create conversation with yourself' });
    }

    // Normalize user IDs (smaller ID first)
    const userA = Math.min(req.userId, userId);
    const userB = Math.max(req.userId, userId);

    // Check if conversation already exists
    let [conversation] = await db.query(
      'SELECT id, user_a_id, user_b_id, created_at FROM conversations WHERE user_a_id = ? AND user_b_id = ?',
      [userA, userB]
    );

    if (!conversation) {
      // Create new conversation
      await db.execute(
        'INSERT INTO conversations (user_a_id, user_b_id) VALUES (?, ?)',
        [userA, userB]
      );
      [conversation] = await db.query(
        'SELECT id, user_a_id, user_b_id, created_at FROM conversations WHERE user_a_id = ? AND user_b_id = ?',
        [userA, userB]
      );
    }

    res.json(conversation);
  } catch (error) {
    console.error('Create conversation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const listConversations = async (req, res) => {
  try {
    const conversations = await db.query(`
      SELECT
        c.id, c.user_a_id, c.user_b_id, c.created_at,
        CASE
          WHEN c.user_a_id = ? THEN c.user_b_id
          ELSE c.user_a_id
        END AS other_user_id,
        u.username, u.email, u.avatar_url,
        m.id as last_message_id, m.content as last_message_content, m.type as last_message_type,
        m.created_at as last_message_time
      FROM conversations c
      JOIN users u ON u.id = CASE WHEN c.user_a_id = ? THEN c.user_b_id ELSE c.user_a_id END
      LEFT JOIN messages m ON m.id = (
        SELECT id FROM messages
        WHERE conversation_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
      )
      WHERE c.user_a_id = ? OR c.user_b_id = ?
      ORDER BY c.updated_at DESC
    `, [req.userId, req.userId, req.userId, req.userId]);

    res.json(conversations);
  } catch (error) {
    console.error('List conversations error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getMessages = async (req, res) => {
  try {
    const { id: conversationId } = req.params;
    const { before, limit = 50 } = req.query;

    let query = 'SELECT id, conversation_id, sender_id, type, content, attachment_key, attachment_name, attachment_size, attachment_mime, created_at, read_at FROM messages WHERE conversation_id = ?';
    const params = [conversationId];

    if (before) {
      query += ' AND created_at < ?';
      params.push(new Date(parseInt(before)));
    }

    query += ' ORDER BY created_at DESC LIMIT ?';
    params.push(parseInt(limit));

    const messages = await db.query(query, params);
    res.json(messages.reverse());
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  createOrGetConversation,
  listConversations,
  getMessages,
};
