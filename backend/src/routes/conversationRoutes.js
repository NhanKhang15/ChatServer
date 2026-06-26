const express = require('express');
const conversationController = require('../controllers/conversationController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.post('/', authMiddleware, conversationController.createOrGetConversation);
router.get('/', authMiddleware, conversationController.listConversations);
router.get('/:id/messages', authMiddleware, conversationController.getMessages);

module.exports = router;
