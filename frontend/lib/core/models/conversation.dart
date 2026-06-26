class Conversation {
  final int id;
  final int userAId;
  final int userBId;
  final int? otherUserId;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String? lastMessageContent;
  final String? lastMessageType;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.otherUserId,
    this.username,
    this.email,
    this.avatarUrl,
    this.lastMessageContent,
    this.lastMessageType,
    this.lastMessageTime,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      userAId: json['user_a_id'],
      userBId: json['user_b_id'],
      otherUserId: json['other_user_id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      lastMessageContent: json['last_message_content'],
      lastMessageType: json['last_message_type'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
