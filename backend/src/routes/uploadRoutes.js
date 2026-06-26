const express = require('express');
const uploadController = require('../controllers/uploadController');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

router.post('/', authMiddleware, upload.single('file'), uploadController.upload);
router.get('/:key', uploadController.getFile);

module.exports = router;
