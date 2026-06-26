# Chat App - Flutter Frontend

A Flutter mobile application for real-time 1-1 chat with JWT authentication, file/image sharing via MinIO.

## Prerequisites

- Flutter SDK (^3.11.5)
- Android SDK / iOS SDK
- Backend server running (see ../backend/README.md)

## Getting Started

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Update the API endpoint in `lib/core/constants.dart`:
   - For Android emulator: `http://10.0.2.2:4000` (default)
   - For physical device: Update to your backend IP (e.g., `http://192.168.1.100:4000`)

### Running

```bash
flutter run
```

For a specific device:
```bash
flutter run -d <device_id>
```

## Features

- **Authentication**: Register and login with JWT
- **Real-time Chat**: 1-1 direct messaging via WebSocket
- **File Sharing**: Send images and file attachments
- **User Search**: Find and start conversations with other users
- **Conversation List**: View all active conversations
- **Message History**: Load previous messages

## Project Structure

```
lib/
  main.dart                         # App entry point
  core/
    constants.dart                  # API & Socket configuration
    models/
      user.dart                     # User model
      conversation.dart             # Conversation model
      message.dart                  # Message model
    providers/
      api_client.dart               # Dio HTTP client with JWT interceptor
      auth_provider.dart            # Authentication state (Riverpod)
      conversations_provider.dart   # Conversations state
      messages_provider.dart        # Messages state
      socket_service.dart           # WebSocket service
  features/
    auth/
      screens/
        login_screen.dart           # Login page
        register_screen.dart        # Registration page
    conversations/
      screens/
        conversations_screen.dart   # List of conversations
        new_chat_screen.dart        # User search & new chat
    chat/
      screens/
        chat_screen.dart            # Chat interface
      widgets/
        message_bubble.dart         # Individual message display
        message_input.dart          # Message input & file upload
```

## API Configuration

Edit `lib/core/constants.dart` to configure:
- API base URL (default: `http://10.0.2.2:4000` for Android emulator)
- Socket URL
- API endpoints

## Troubleshooting

### "Connection refused" error
- Ensure backend server is running
- Check if IP/port in `constants.dart` is correct
- For emulator, use `10.0.2.2` for localhost

### Image picker / File picker issues
- Make sure app has permission to access camera, gallery, and files
- On Android 6+, runtime permissions are required

### WebSocket connection error
- Verify backend server has Socket.IO enabled
- Check network connectivity between device and server
- Ensure JWT token is valid

## Building for Release

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

## Notes

- Messages are stored locally and synced via WebSocket
- File uploads go through `/api/upload` endpoint to MinIO
- JWT token is stored securely using `flutter_secure_storage`
- Images are displayed using presigned URLs from MinIO
