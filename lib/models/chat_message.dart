import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isRead;
  final String ticketId;
  final MessageStatus status;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.isRead = false,
    required this.ticketId,
    this.status = MessageStatus.sending,
    this.isTyping = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      ticketId: json['ticketId'],
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'ticketId': ticketId,
      'status': status.toString(),
      'isTyping': isTyping,
    };
  }

  types.Message toChatUIMessage() {
    return types.TextMessage(
      author: types.User(
        id: senderId,
        firstName: senderName,
      ),
      id: id,
      text: text,
      createdAt: timestamp.millisecondsSinceEpoch,
      status: _convertStatus(),
    );
  }

  types.Status _convertStatus() {
    switch (status) {
      case MessageStatus.sending:
        return types.Status.sending;
      case MessageStatus.sent:
        return types.Status.sent;
      case MessageStatus.delivered:
        return types.Status.delivered;
      case MessageStatus.read:
        return types.Status.seen;
      case MessageStatus.error:
        return types.Status.error;
    }
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    String? senderId,
    String? senderName,
    DateTime? timestamp,
    bool? isRead,
    String? ticketId,
    MessageStatus? status,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      ticketId: ticketId ?? this.ticketId,
      status: status ?? this.status,
      isTyping: isTyping ?? this.isTyping,
    );
  }
} 