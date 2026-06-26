function getTables() {
  return {
    users: `
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        avatar_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `,
    conversations: `
      CREATE TABLE IF NOT EXISTS conversations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_a_id INT NOT NULL,
        user_b_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_conversation (user_a_id, user_b_id),
        FOREIGN KEY (user_a_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (user_b_id) REFERENCES users(id) ON DELETE CASCADE,
        CHECK (user_a_id < user_b_id)
      )
    `,
    messages: `
      CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        conversation_id INT NOT NULL,
        sender_id INT NOT NULL,
        type ENUM('text', 'image', 'file') DEFAULT 'text',
        content TEXT,
        attachment_key VARCHAR(500),
        attachment_name VARCHAR(500),
        attachment_size INT,
        attachment_mime VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        read_at TIMESTAMP NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_conversation_created (conversation_id, created_at)
      )
    `,
  };
}

module.exports = { getTables };
