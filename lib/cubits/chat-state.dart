part of 'chat_cubit.dart';

class ChatState {
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> messages;
  final String? currentConversationId;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.conversations = const [],
    this.messages = const [],
    this.currentConversationId,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? messages,
    String? currentConversationId,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
