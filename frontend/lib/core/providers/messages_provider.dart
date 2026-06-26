import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/message.dart';
import '../constants.dart';
import 'api_client.dart';
import 'socket_service.dart';

final messagesProvider =
    NotifierProvider.family<MessagesNotifier, MessagesState, int>(
  (conversationId) => MessagesNotifier(conversationId),
);

class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MessagesNotifier extends Notifier<MessagesState> {
  final int conversationId;
  late ApiClient _apiClient;

  MessagesNotifier(this.conversationId);

  @override
  MessagesState build() {
    _apiClient = ref.watch(apiClientProvider);
    // Socket listeners are set up lazily via setupSocketListeners()
    // after the socket has been connected (called from ChatScreen.initState)
    return MessagesState();
  }

  void setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);

    // Listen for new messages from other users
    socketService.on(AppConstants.socketEventMessageNew, (data) {
      final message = Message.fromJson(data);
      if (message.conversationId == conversationId) {
        addMessage(message);
      }
    });

    // Listen for read receipts
    socketService.on(AppConstants.socketEventMessageRead, (data) {
      final messageId = data['messageId'];
      markMessageAsRead(messageId);
    });
  }

  Future<void> fetchMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.conversationsEndpoint}/$conversationId/messages',
        queryParameters: {'limit': 50},
      );
      final messages = (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
      state = state.copyWith(messages: messages, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['error'] ?? 'Failed to fetch messages',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  void addMessage(Message message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  void markMessageAsRead(int messageId) {
    final updatedMessages = state.messages.map((m) {
      if (m.id == messageId) {
        return Message(
          id: m.id,
          conversationId: m.conversationId,
          senderId: m.senderId,
          type: m.type,
          content: m.content,
          attachmentKey: m.attachmentKey,
          attachmentName: m.attachmentName,
          attachmentSize: m.attachmentSize,
          attachmentMime: m.attachmentMime,
          createdAt: m.createdAt,
          readAt: DateTime.now(),
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  Future<Map<String, dynamic>?> uploadFile(
    List<int> fileBytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await _apiClient.dio.post(
        AppConstants.uploadEndpoint,
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data?['error'] ?? 'Upload failed',
      );
      return null;
    } catch (e) {
      state = state.copyWith(error: 'An unexpected error occurred');
      return null;
    }
  }
}
