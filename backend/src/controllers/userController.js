const db = require('../db/Database');

const listUsers = async (req, res) => {
  try {
    const { search } = req.query;
    let query = 'SELECT id, username, email, avatar_url, created_at FROM users WHERE id != ?';
    const params = [req.userId];

    if (search) {
      query += ' AND (username LIKE ? OR email LIKE ?)';
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern);
    }

    const users = await db.query(query, params);
    res.json(users);
  } catch (error) {
    console.error('List users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  listUsers,
};
