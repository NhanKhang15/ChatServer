import '../constants.dart';

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String type; // 'text', 'image', 'file'
  final String? content;
  final String? attachmentKey;
  final String? attachmentName;
  final int? attachmentSize;
  final String? attachmentMime;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    this.attachmentKey,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentMime,
    required this.createdAt,
    this.readAt,
  });

  /// Full proxy URL for the attachment, built from attachmentKey.
  /// Returns null if there is no attachment.
  String? get attachmentUrl {
    if (attachmentKey == null) return null;
    final encoded = Uri.encodeComponent(attachmentKey!);
    return '${AppConstants.apiBaseUrl}${AppConstants.filesEndpoint}/$encoded';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      type: json['type'],
      content: json['content'],
      attachmentKey: json['attachment_key'],
      attachmentName: json['attachment_name'],
      attachmentSize: json['attachment_size'],
      attachmentMime: json['attachment_mime'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'type': type,
      'content': content,
      'attachment_key': attachmentKey,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
      'attachment_mime': attachmentMime,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
