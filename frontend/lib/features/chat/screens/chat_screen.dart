import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/messages_provider.dart';
import '../../../core/providers/socket_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String username;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.username,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Connect to WebSocket first
      final token = ref.read(authProvider).token;
      if (token != null) {
        await ref.read(socketServiceProvider).connect(token);

        // Setup socket listeners after connection is established
        ref
            .read(messagesProvider(widget.conversationId).notifier)
            .setupSocketListeners();
      }

      // Fetch initial messages
      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .fetchMessages();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.messages.isEmpty
                    ? const Center(child: Text('No messages'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.messages.length,
                        itemBuilder: (context, index) {
                          final message = messages.messages[index];
                          final isCurrentUser =
                              message.senderId == auth.user?.id;

                          return MessageBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                          );
                        },
                      ),
          ),
          MessageInput(conversationId: widget.conversationId),
        ],
      ),
    );
  }
}
