import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

enum MessageType {
  text(0),
  image(1),
  video(2),
  audio(3);

  final int value;
  const MessageType(this.value);
}

class ChatMessage {
  final String id;
  final String? content;
  final int senderId;
  final String? senderName; // Added sender name field
  final DateTime createdAt;
  final bool delivered;
  final bool seen;
  final MessageType type;
  final String? mediaUrl;
  final int? recordDuration;
  final String? ticketId;
  final int? fileSize; // Added file size field for media messages
 // final int senderId; // Add this
  final int receiverId; // Add this
  final int conversationId; // Add this

  ChatMessage({
    required this.conversationId,
    required this.receiverId,
    required this.id,
    this.content,
    required this.senderId,
    this.senderName,
    required this.createdAt,
    this.delivered = false,
    this.seen = false,
    required this.type,
    this.mediaUrl,
    this.recordDuration,
    this.ticketId,
    this.fileSize,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
       receiverId: json['receiver_id'] ?? 0, // Add this
      conversationId: json['conversation_id'] ?? 0, // Add this
      id: json['id'],
      content: json['content'],
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'],
      createdAt: DateTime.parse(json['created_at']),
      delivered: json['delivered'] ?? false,
      seen: json['seen'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.value == (json['type'] ?? 0),
        orElse: () => MessageType.text,
      ),
      mediaUrl: json['media'],
      recordDuration: json['record_duration'],
      ticketId: json['ticket_id']?.toString(),
      fileSize: json['file_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'type': type.value,
      'media': mediaUrl,
      'record_duration': recordDuration,
      'ticket_id': ticketId,
      'file_size': fileSize,
    };
  }

  types.Message toChatUIMessage(String currentUserId) {
    final author = types.User(
      id: senderId.toString(),
      firstName: senderName ?? 'User', // Use actual name if available
    );

    switch (type) {
      case MessageType.text:
        return types.TextMessage(
          author: author,
          id: id,
          text: content ?? '',
          createdAt: createdAt.millisecondsSinceEpoch,
          status: _convertStatus(),
        );
      case MessageType.image:
        return types.ImageMessage(
          author: author,
          id: id,
          uri: mediaUrl ?? '',
          name: mediaUrl?.split('/').last ?? 'image',
          size: fileSize ?? 0,
          createdAt: createdAt.millisecondsSinceEpoch,
          status: _convertStatus(),
        );
      // Add cases for other message types as needed
      default:
        return types.TextMessage(
          author: author,
          id: id,
          text: content ?? '[Unsupported message type]',
          createdAt: createdAt.millisecondsSinceEpoch,
          status: _convertStatus(),
        );
    }
  }

  types.Status _convertStatus() {
    if (seen) return types.Status.seen;
    if (delivered) return types.Status.delivered;
    return types.Status.sent;
  }
}