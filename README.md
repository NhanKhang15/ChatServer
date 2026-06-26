# Chat App - Full Stack

A complete real-time chat application with Node.js/Express backend and Flutter mobile frontend.

## Architecture

### Backend (Node.js)
- **Framework**: Express.js + Socket.IO
- **Database**: MySQL
- **File Storage**: MinIO (S3-compatible)
- **Authentication**: JWT
- **Docker**: Full Docker Compose setup

### Frontend (Flutter)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **WebSocket**: socket_io_client
- **Storage**: flutter_secure_storage

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (for frontend development)
- Node.js 20+ (for local backend development without Docker)

### Run Everything

1. Start the backend (with MySQL and MinIO):
```bash
cd backend
docker-compose up --build
```

The backend will be available at `http://localhost:4000`
MinIO console at `http://localhost:9001` (user: `minioadmin`, pass: `minioadmin`)

2. In another terminal, run the Flutter app:
```bash
cd frontend
flutter pub get
flutter run
```

## Folder Structure

```
.
├── backend/                    # Node.js Express server
│   ├── src/
│   │   ├── config/            # Configuration
│   │   ├── db/                # Database class & schema
│   │   ├── services/          # MinIO service
│   │   ├── middleware/        # Auth & upload middleware
│   │   ├── controllers/       # API controllers
│   │   ├── routes/            # API routes
│   │   ├── socket/            # WebSocket handlers
│   │   ├── app.js             # Express app
│   │   └── server.js          # Server entry point
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── package.json
│   └── README.md
│
├── frontend/                   # Flutter mobile app
│   ├── lib/
│   │   ├── core/              # Models, providers, services
│   │   ├── features/          # Feature modules (auth, chat, etc)
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md                   # This file
```

## Development

### Backend
```bash
cd backend
# With Docker
docker-compose up --build
# Or locally (if MySQL & MinIO are running)
npm install
npm start
```

See [backend/README.md](backend/README.md) for details.

### Frontend
```bash
cd frontend

# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

See [frontend/README.md](frontend/README.md) for details.

## API Documentation

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Current user (requires JWT)

### Users
- `GET /api/users?search=query` - List/search users

### Conversations
- `POST /api/conversations` - Create/get conversation
- `GET /api/conversations` - List conversations
- `GET /api/conversations/:id/messages` - Get messages

### File Upload
- `POST /api/upload` - Upload file
- `GET /api/files/:key` - Get presigned URL

## WebSocket Events

### Send (Client → Server)
- `message:send` - Send message
- `typing` - Typing notification
- `message:read` - Mark as read

### Receive (Server → Client)
- `message:new` - New message
- `typing` - User typing
- `message:read` - Message read

## Configuration

### Backend
Create `backend/.env`:
```
PORT=4000
NODE_ENV=development
DB_HOST=mysql
DB_USER=root
DB_PASSWORD=root
JWT_SECRET=your-secret-key
MINIO_ENDPOINT=minio
```

### Frontend
Edit `frontend/lib/core/constants.dart`:
```dart
// Android emulator
static const String apiBaseUrl = 'http://10.0.2.2:4000';

// Physical device
static const String apiBaseUrl = 'http://192.168.1.X:4000';
```

## Features

✅ User authentication (JWT)
✅ 1-1 direct messaging
✅ Real-time chat via WebSocket
✅ Message history
✅ Image sharing (via MinIO)
✅ File attachment support
✅ User search
✅ Typing indicators
✅ Message read receipts
✅ Conversation list
✅ Secure token storage

## Default Credentials

- **MinIO**: `minioadmin` / `minioadmin`
- **MySQL**: user `root`, password `root`

## Troubleshooting

### Backend won't start
- Check Docker is running: `docker ps`
- Check port 4000 is free: `lsof -i :4000`
- Check MySQL/MinIO services: `docker ps`

### Flutter can't connect to backend
- Verify backend is running on `http://10.0.2.2:4000` (emulator)
- Or update IP in `constants.dart` for physical device
- Check firewall settings

### WebSocket connection fails
- Backend must have Socket.IO running (default on port 4000)
- Ensure you're using correct token in WebSocket auth

## Security Notes

⚠️ **IMPORTANT**: This is a development setup. For production:
- Change all default passwords in `.env`
- Use HTTPS/WSS instead of HTTP/WS
- Enable proper CORS settings
- Implement rate limiting
- Add request validation
- Use strong JWT_SECRET
- Enable database backups
- Set up proper file storage encryption

## License

MIT