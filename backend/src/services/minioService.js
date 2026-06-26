const { Client } = require('minio');
const env = require('../config/env');

class MinIOService {
  constructor() {
    // Single client using internal Docker hostname — works from inside the container
    this.client = new Client({
      endPoint: env.MINIO_ENDPOINT,
      port: parseInt(env.MINIO_PORT),
      useSSL: env.MINIO_USE_SSL,
      accessKey: env.MINIO_ACCESS_KEY,
      secretKey: env.MINIO_SECRET_KEY,
    });
  }

  async ensureBucket() {
    try {
      const exists = await this.client.bucketExists(env.MINIO_BUCKET);
      if (!exists) {
        await this.client.makeBucket(env.MINIO_BUCKET, 'us-east-1');
        console.log(`✓ MinIO bucket '${env.MINIO_BUCKET}' created`);
      } else {
        console.log(`✓ MinIO bucket '${env.MINIO_BUCKET}' already exists`);
      }
    } catch (error) {
      console.error('✗ Failed to ensure bucket:', error.message);
      throw error;
    }
  }

  async uploadFile(buffer, key, mimeType = 'application/octet-stream') {
    try {
      await this.client.putObject(
        env.MINIO_BUCKET,
        key,
        buffer,
        buffer.length,
        { 'Content-Type': mimeType }
      );
      console.log(`✓ File uploaded: ${key}`);
      return key;
    } catch (error) {
      console.error('✗ Failed to upload file:', error.message);
      throw error;
    }
  }

  /**
   * Stream a file from MinIO directly to a response object.
   * Avoids presigned URLs entirely — no hostname/signature mismatch issues.
   */
  async streamFile(key, res) {
    try {
      const stat = await this.client.statObject(env.MINIO_BUCKET, key);
      res.setHeader('Content-Type', stat.metaData['content-type'] || 'application/octet-stream');
      res.setHeader('Content-Length', stat.size);
      res.setHeader('Cache-Control', 'private, max-age=86400');

      const stream = await this.client.getObject(env.MINIO_BUCKET, key);
      stream.pipe(res);

      stream.on('error', (err) => {
        console.error('✗ Stream error:', err.message);
        if (!res.headersSent) {
          res.status(500).json({ error: 'Failed to stream file' });
        }
      });
    } catch (error) {
      console.error('✗ Failed to stream file:', error.message);
      throw error;
    }
  }

  async deleteFile(key) {
    try {
      await this.client.removeObject(env.MINIO_BUCKET, key);
      console.log(`✓ File deleted: ${key}`);
      return true;
    } catch (error) {
      console.error('✗ Failed to delete file:', error.message);
      throw error;
    }
  }
}

module.exports = new MinIOService();
