import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants.dart';

final socketServiceProvider = Provider((ref) {
  return SocketService();
});

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(String token) async {
    // Avoid reconnecting if already connected
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(10)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onConnectError((data) {
      print('Socket connect error: $data');
    });

    _socket!.onError((data) {
      print('Socket error: $data');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  void sendMessage({
    required int conversationId,
    required String type,
    String? content,
    Map<String, dynamic>? attachment,
  }) {
    _socket?.emit(
      AppConstants.socketEventMessageSend,
      {
        'conversationId': conversationId,
        'type': type,
        'content': content,
        'attachment': attachment,
      },
    );
  }

  void sendTyping(int conversationId) {
    _socket?.emit(AppConstants.socketEventTyping, {
      'conversationId': conversationId,
    });
  }

  void markMessageAsRead({
    required int messageId,
    required int conversationId,
  }) {
    _socket?.emit(
      AppConstants.socketEventMessageRead,
      {
        'messageId': messageId,
        'conversationId': conversationId,
      },
    );
  }

  void on(String event, dynamic Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    if (_socket?.connected == true) {
      _socket!.disconnect();
    }
  }

  void dispose() {
    disconnect();
    _socket = null;
  }
}
