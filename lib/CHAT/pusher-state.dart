

abstract class PusherState {}

class PusherInitial extends PusherState {}

class ConversationUpdated extends PusherState {
  final Map<String, dynamic> data;
  ConversationUpdated(this.data);
}

class NewMessageReceived extends PusherState {
  final Map<String, dynamic> data;
  NewMessageReceived(this.data);
}

class MessageDeleted extends PusherState {
  final String messageId;
  MessageDeleted(this.messageId);
}

class PusherError extends PusherState {
  final String message;
  PusherError(this.message);
}

class PusherConnected extends PusherState {}

class PusherConnecting extends PusherState {}

class PusherReconnecting extends PusherState {}

class PusherDisconnected extends PusherState {}