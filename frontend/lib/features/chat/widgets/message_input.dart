import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import '../../../core/providers/socket_service.dart';
import '../../../core/providers/messages_provider.dart';

class MessageInput extends ConsumerStatefulWidget {
  final int conversationId;

  const MessageInput({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  late TextEditingController _messageController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getMimeType(String? extension) {
    if (extension == null) return 'application/octet-stream';
    final ext = extension.toLowerCase();
    switch (ext) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'html':
        return 'text/html';
      case 'csv':
        return 'text/csv';
      // Archive
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      // Audio/Video
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _uploadAndSendImage(XFile image) async {
    setState(() => _isUploading = true);
    try {
      final bytes = await image.readAsBytes();
      final fileName = image.name;
      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = _getMimeType(ext);

      final uploadData = await ref
          .read(messagesProvider(widget.conversationId).notifier)
          .uploadFile(bytes, fileName, mimeType);

      if (uploadData != null && mounted) {
        // Send image message via WebSocket
        ref.read(socketServiceProvider).sendMessage(
          conversationId: widget.conversationId,
          type: 'image',
          attachment: {
            'key': uploadData['key'],
            'url': uploadData['url'],
            'name': uploadData['name'],
            'size': uploadData['size'],
            'mime': uploadData['mime'],
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image sent')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _uploadAndSendFile(file_picker.PlatformFile file) async {
    setState(() => _isUploading = true);
    try {
      List<int>? fileBytes = file.bytes;
      if (fileBytes == null) {
        if (!kIsWeb && file.path != null) {
          final fileObj = io.File(file.path!);
          fileBytes = await fileObj.readAsBytes();
        }
      }

      if (fileBytes == null) {
        throw Exception('Could not read file: no bytes or path available');
      }

      final mimeType = _getMimeType(file.extension);

      final uploadData = await ref
          .read(messagesProvider(widget.conversationId).notifier)
          .uploadFile(fileBytes, file.name, mimeType);

      if (uploadData != null && mounted) {
        // Send file message via WebSocket
        ref.read(socketServiceProvider).sendMessage(
          conversationId: widget.conversationId,
          type: 'file',
          attachment: {
            'key': uploadData['key'],
            'url': uploadData['url'],
            'name': uploadData['name'],
            'size': uploadData['size'],
            'mime': uploadData['mime'],
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File sent')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isUploading,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Camera'),
                        onTap: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (image != null) {
                            _uploadAndSendImage(image);
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Gallery'),
                        onTap: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            _uploadAndSendImage(image);
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('File'),
                        onTap: () async {
                          try {
                            final result =
                                await file_picker.FilePicker.pickFiles(withData: true);
                            if (result != null && result.files.isNotEmpty) {
                              _uploadAndSendFile(result.files.first);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error picking file')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                    icon: const Icon(Icons.add, color: Colors.white),
                    offset: const Offset(0, -200),
                  ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isUploading
                  ? null
                  : () {
                      if (_messageController.text.isNotEmpty) {
                        ref.read(socketServiceProvider).sendMessage(
                          conversationId: widget.conversationId,
                          type: 'text',
                          content: _messageController.text,
                        );
                        _messageController.clear();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
