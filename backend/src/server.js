const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const database = require('./db/Database');
const minioService = require('./services/minioService');
const initializeSocket = require('./socket/socketServer');
const env = require('./config/env');

const server = http.createServer(app);

// Initialize Socket.IO
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Initialize Socket events
initializeSocket(io);

// Make io available globally for other modules if needed
global.io = io;

async function bootstrap() {
  try {
    console.log('🚀 Starting Chat Server...\n');

    // Initialize database
    console.log('📊 Initializing Database...');
    await database.init();

    // Initialize MinIO
    console.log('\n📦 Initializing MinIO Storage...');
    await minioService.ensureBucket();

    // Start server
    server.listen(env.PORT, () => {
      console.log(`\n✓ Server is running on port ${env.PORT}`);
      console.log(`✓ WebSocket server ready`);
      console.log(`✓ Environment: ${env.NODE_ENV}`);
    });
  } catch (error) {
    console.error('✗ Bootstrap error:', error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('\n📋 SIGTERM received, shutting down gracefully...');
  server.close(async () => {
    await database.close();
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('\n📋 SIGINT received, shutting down gracefully...');
  server.close(async () => {
    await database.close();
    process.exit(0);
  });
});

// Start application
bootstrap();
