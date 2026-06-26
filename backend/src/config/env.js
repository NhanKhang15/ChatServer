require('dotenv').config();

module.exports = {
  // Server
  PORT: process.env.PORT || 4000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  // Public base URL of the backend (used to build file proxy URLs)
  API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:4000',

  // Database
  DB_HOST: process.env.DB_HOST || 'mysql',
  DB_PORT: process.env.DB_PORT || 3306,
  DB_USER: process.env.DB_USER || 'root',
  DB_PASSWORD: process.env.DB_PASSWORD || 'root',
  DB_NAME: process.env.DB_NAME || 'chatapp',

  // JWT
  JWT_SECRET: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  JWT_EXPIRY: process.env.JWT_EXPIRY || '7d',

  // MinIO
  MINIO_ENDPOINT: process.env.MINIO_ENDPOINT || 'minio',
  MINIO_PORT: process.env.MINIO_PORT || 9000,
  MINIO_ACCESS_KEY: process.env.MINIO_ACCESS_KEY || 'minioadmin',
  MINIO_SECRET_KEY: process.env.MINIO_SECRET_KEY || 'minioadmin',
  MINIO_BUCKET: process.env.MINIO_BUCKET || 'chat-uploads',
  MINIO_USE_SSL: process.env.MINIO_USE_SSL === 'true',
  // Public URL that browsers can reach MinIO at (different from internal Docker hostname)
  MINIO_PUBLIC_URL: process.env.MINIO_PUBLIC_URL || null,
};
