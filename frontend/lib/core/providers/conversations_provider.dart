import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/conversation.dart';
import '../models/user.dart';
import '../constants.dart';
import 'api_client.dart';

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, ConversationsState>(
  ConversationsNotifier.new,
);

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ConversationsNotifier extends Notifier<ConversationsState> {
  late ApiClient _apiClient;

  @override
  ConversationsState build() {
    _apiClient = ref.watch(apiClientProvider);
    return ConversationsState();
  }

  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get(AppConstants.conversationsEndpoint);
      final conversations = (response.data as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
      state = state.copyWith(conversations: conversations, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['error'] ?? 'Failed to fetch conversations',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<Conversation?> createOrGetConversation(int userId) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.conversationsEndpoint,
        data: {'userId': userId},
      );
      return Conversation.fromJson(response.data);
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data?['error'] ?? 'Failed to create conversation',
      );
      return null;
    } catch (e) {
      state = state.copyWith(error: 'An unexpected error occurred');
      return null;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiClient.dio.get(
        AppConstants.usersEndpoint,
        queryParameters: query.isNotEmpty ? {'search': query} : null,
      );
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
