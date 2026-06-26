const minioService = require('../services/minioService');
const env = require('../config/env');

const upload = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    const { originalname, mimetype, size, buffer } = req.file;
    const key = `${Date.now()}-${originalname}`;

    await minioService.uploadFile(buffer, key, mimetype);

    // Return a backend proxy URL instead of a presigned MinIO URL.
    // This avoids hostname/signature issues when MinIO is inside Docker.
    const fileUrl = `${env.API_BASE_URL}/api/files/${encodeURIComponent(key)}`;

    res.json({
      key,
      url: fileUrl,
      name: originalname,
      size,
      mime: mimetype,
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'Failed to upload file' });
  }
};

const getFile = async (req, res) => {
  try {
    const key = decodeURIComponent(req.params.key);
    await minioService.streamFile(key, res);
  } catch (error) {
    console.error('Get file error:', error);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Failed to get file' });
    }
  }
};

module.exports = {
  upload,
  getFile,
};
