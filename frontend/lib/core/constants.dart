// API Configuration
// For Android emulator running on local machine: 10.0.2.2:4000
// For physical device on LAN: 192.168.x.x:4000 (update with your actual IP)
// For iOS simulator on Mac: localhost:4000

class AppConstants {
  // Change this to your actual backend IP/hostname
  static const String apiBaseUrl = 'http://localhost:4000';

  // For physical device, use:
  // static const String apiBaseUrl = 'http://192.168.1.100:4000'; // Replace with your IP

  static const String socketUrl = apiBaseUrl;

  // API Endpoints
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String usersEndpoint = '/api/users';
  static const String conversationsEndpoint = '/api/conversations';
  static const String uploadEndpoint = '/api/upload';
  static const String filesEndpoint = '/api/files';

  // Socket Events
  static const String socketEventMessageSend = 'message:send';
  static const String socketEventMessageNew = 'message:new';
  static const String socketEventTyping = 'typing';
  static const String socketEventMessageRead = 'message:read';
  static const String socketEventError = 'error';
}
