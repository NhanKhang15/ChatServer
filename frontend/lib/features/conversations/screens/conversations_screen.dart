import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/conversations_provider.dart';
import 'new_chat_screen.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: conversations.isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No conversations yet'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NewChatScreen(),
                            ),
                          );
                        },
                        child: const Text('Start a chat'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: conversations.conversations.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final conversation = conversations.conversations[index];
                    final lastMessageTime = conversation.lastMessageTime;
                    final timeString = lastMessageTime != null
                        ? DateFormat('HH:mm').format(lastMessageTime)
                        : '';

                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/chat',
                          arguments: {
                            'conversationId': conversation.id,
                            'username': conversation.username,
                          },
                        );
                      },
                      leading: CircleAvatar(
                        child: Text(
                          (conversation.username ?? 'U').substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(conversation.username ?? 'Unknown'),
                      subtitle: Text(
                        conversation.lastMessageContent ?? 'No messages',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(timeString),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewChatScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
