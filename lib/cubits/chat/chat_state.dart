

import 'package:tech_app/models/chat_message.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessageSending extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<ChatMessage> messages;

  MessagesLoaded(this.messages);
}

class MessageSentSuccess extends MessagesState {
  final ChatMessage message;

  MessageSentSuccess(this.message);
}

class MessageError extends MessagesState {
  final String message;

  MessageError(this.message);
}