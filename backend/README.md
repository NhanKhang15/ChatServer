# Chat Server Backend

Node.js + Express + Socket.IO chat server with JWT authentication, MySQL database, and MinIO file storage.

## Prerequisites

- Docker & Docker Compose installed
- Node.js 20+ (for local development without Docker)

## Quick Start with Docker

```bash
docker-compose up --build
```

The server will start on `http://localhost:4000` and MinIO console will be available at `http://localhost:9001`.

### Default Credentials
- **MinIO**: `minioadmin` / `minioadmin`
- **MySQL**: user `root`, password `root`

### Environment Variables (Docker)
Tất cả biến môi trường đã được set trong `docker-compose.yml`:
- `MYSQL_ROOT_PASSWORD: root` — password root của MySQL container
- `DB_HOST: mysql` — hostname MySQL (service name trong docker-compose)
- `DB_PASSWORD: root` — mật khẩu kết nối MySQL (backend sử dụng)
- `MINIO_ENDPOINT: minio` — hostname MinIO (service name trong docker-compose)
- `JWT_SECRET` — khóa bí mật cho JWT

Không cần chỉnh sửa biến khi chạy Docker, trừ khi bạn muốn thay đổi credential mặc định.

## Local Development (without Docker)

1. Install MySQL 8 and MinIO locally
2. File `.env` đã sẵn sàng (copy từ `.env.example`). Update nếu cần:
   ```bash
   # Nếu MySQL chạy ở máy local (không phải Docker):
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=root
   
   # Nếu MinIO chạy ở máy local:
   MINIO_ENDPOINT=localhost
   MINIO_PORT=9000
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm start
   ```

**Lưu ý:** Khi dùng Docker Compose, các service (mysql, minio) được tham chiếu bằng service name (`mysql`, `minio`). Khi chạy local, phải dùng `localhost` hoặc IP thực.

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (requires JWT)

### Users
- `GET /api/users?search=query` - List/search users (requires JWT)

### Conversations
- `POST /api/conversations` - Create or get 1-1 conversation (requires JWT)
- `GET /api/conversations` - List conversations (requires JWT)
- `GET /api/conversations/:id/messages?before=&limit=50` - Get message history (requires JWT)

### File Upload
- `POST /api/upload` - Upload file to MinIO (requires JWT)
- `GET /api/files/:key` - Get presigned URL for file

## WebSocket Events

### Client -> Server
- `message:send` - Send message
- `typing` - Notify typing
- `message:read` - Mark message as read

### Server -> Client
- `message:new` - New message received
- `typing` - User is typing
- `message:read` - Message marked as read
- `error` - Error occurred

## Architecture

- **Express** - REST API
- **Socket.IO** - Real-time WebSocket communication
- **MySQL** - Data persistence
- **MinIO** - S3-compatible file storage
- **JWT** - Authentication

## Environment Variables

See `.env.example` for all available configuration options.

## Project Structure

```
src/
  config/env.js           - Environment configuration
  db/
    Database.js           - Database connection & query class
    schema.js             - SQL schema definitions
  services/
    minioService.js       - MinIO S3 client
  middleware/
    auth.js               - JWT verification
    upload.js             - Multer file upload
  controllers/
    authController.js     - Auth logic
    userController.js     - User queries
    conversationController.js - Conversation logic
    uploadController.js   - File upload
  routes/
    authRoutes.js         - Auth endpoints
    userRoutes.js         - User endpoints
    conversationRoutes.js - Conversation endpoints
    uploadRoutes.js       - Upload endpoints
  socket/
    socketServer.js       - Socket.IO events
  app.js                  - Express app setup
  server.js               - HTTP server entry point
```
