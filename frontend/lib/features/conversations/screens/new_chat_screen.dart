import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/conversations_provider.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  List<User> _users = [];
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    final users = await ref
        .read(conversationsProvider.notifier)
        .searchUsers('');
    setState(() {
      _users = users;
    });
  }

  void _searchUsers(String query) async {
    final users = await ref
        .read(conversationsProvider.notifier)
        .searchUsers(query);
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _users.isEmpty
                ? const Center(
                    child: Text('No users found'),
                  )
                : ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return ListTile(
                        onTap: () async {
                          final conversation = await ref
                              .read(conversationsProvider.notifier)
                              .createOrGetConversation(user.id);
                          if (conversation != null && mounted) {
                            Navigator.of(context).pushReplacementNamed(
                              '/chat',
                              arguments: {
                                'conversationId': conversation.id,
                                'username': user.username,
                              },
                            );
                          }
                        },
                        leading: CircleAvatar(
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.email),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
