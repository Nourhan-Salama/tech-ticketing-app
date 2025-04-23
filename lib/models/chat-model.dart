

import 'package:tech_app/models/message-model.dart';

class ChatModel {
  final String chatId;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final String time;
  final List<Message> messages; 

  ChatModel({
    required this.chatId,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.time,
    required this.messages,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      time: json['time'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => Message.fromJson(msg))
          .toList() ?? [], 
    );
  }
}

