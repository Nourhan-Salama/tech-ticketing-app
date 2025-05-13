class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String conversationId;
  final DateTime createdAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      conversationId: json['conversationId'],
      createdAt: DateTime.parse(json['createdAt']),
      isMe: json['isMe'] ?? false,
    );
  }
}

