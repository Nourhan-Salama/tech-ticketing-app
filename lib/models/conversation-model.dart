class Conversation {
  final String id;
  final int type;
  final bool pinned;
  final OtherUser? otherUser;
  final LatestMessage? latestMessage;
  final LatestReaction? latestReaction;
  final int? ticketId;

  Conversation({
    required this.id,
    required this.type,
    required this.pinned,
    this.otherUser,
    this.latestMessage,
    this.latestReaction,
    this.ticketId,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      type: json['type'] as int? ?? 0,
      pinned: json['pinned'] as bool? ?? false,
      otherUser: json['other_user'] != null 
          ? OtherUser.fromJson(json['other_user']) 
          : null,
      latestMessage: json['latest_message'] != null
          ? LatestMessage.fromJson(json['latest_message'])
          : null,
      latestReaction: json['latest_reaction'] != null
          ? LatestReaction.fromJson(json['latest_reaction'])
          : null,
      ticketId: json['ticket_id'] as int?,
    );
  }

  String get title => otherUser?.name ?? 'New Conversation';
  String get avatarUrl => otherUser?.avatar ?? 'https://via.placeholder.com/150';
  String get lastMessage => latestMessage?.content ?? 'No messages yet';
  DateTime get lastMessageTime => latestMessage?.createdAt ?? DateTime.now();
  bool get unread => latestMessage?.seen == false;

  Conversation copyWith({
    String? id,
    int? type,
    bool? pinned,
    OtherUser? otherUser,
    LatestMessage? latestMessage,
    LatestReaction? latestReaction,
    int? ticketId,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      pinned: pinned ?? this.pinned,
      otherUser: otherUser ?? this.otherUser,
      latestMessage: latestMessage ?? this.latestMessage,
      latestReaction: latestReaction ?? this.latestReaction,
      ticketId: ticketId ?? this.ticketId,
    );
  }
}

class OtherUser {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String avatar;
  final int type;
  final bool online;
  final DateTime? lastTimeSeen;

  OtherUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.avatar,
    required this.type,
    required this.online,
    this.lastTimeSeen,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    print('Creating OtherUser from JSON: $json');
    return OtherUser(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      type: json['type'] ?? 0,
      online: json['online'] ?? false,
      lastTimeSeen: json['last_time_seen'] != null 
          ? DateTime.parse(json['last_time_seen']) 
          : null,
    );
  }
}

class LatestMessage {
  final String id;
  final int senderId;
  final int type;
  final bool seen;
  final DateTime createdAt;
  final int? recordDuration;
  final String content;

  LatestMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.seen,
    required this.createdAt,
    this.recordDuration,
    required this.content,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    print('Creating LatestMessage from JSON: $json');
    return LatestMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? 0,
      type: json['type'] ?? 0,
      seen: json['seen'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      recordDuration: json['record_duration'],
      content: json['content'] ?? '',
    );
  }
}

class LatestReaction {
  final String value;
  final LatestMessage message;

  LatestReaction({
    required this.value,
    required this.message,
  });

  factory LatestReaction.fromJson(Map<String, dynamic> json) {
    print('Creating LatestReaction from JSON: $json');
    return LatestReaction(
      value: json['value'] ?? '',
      message: LatestMessage.fromJson(json['message']),
    );
  }
}