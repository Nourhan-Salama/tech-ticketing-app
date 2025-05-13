// cubits/get-chat-cubit.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:tech_app/models/conversation-model.dart';
import 'package:tech_app/models/msg-model.dart';
import 'package:tech_app/services/conversations-service.dart';
import 'package:tech_app/services/pusher-service.dart';

class ChatCubit extends Cubit<ChatState> {
  final ConversationsService chatService;
  late String _currentUserId;

  ChatCubit({required this.chatService}) : super(ChatInitial());

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    emit(ChatLoaded(
      conversations: [],
      messages: [],
      currentUserId: userId,
      isLoading: true,
    ));

    try {
      await PusherService.initPusher(userId: userId);
      PusherService.onEvent = _handlePusherEvent;

      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isLoading: false));
      }
    } catch (e) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(
          error: 'Failed to initialize chat',
          isLoading: false,
        ));
      }
    }
  }

  // Future<void> loadConversationsForTicket(int ticketId) async {
  //   print('Loading conversations for ticket $ticketId');

  //   if (state is! ChatLoaded) {
  //     print('Current state is not ChatLoaded. Cannot load conversations.');
  //     return;
  //   }

  //   final currentState = state as ChatLoaded;
  //   emit(currentState.copyWith(isLoading: true));

  //   try {
  //     final conversations = await chatService.fetchConversationsForTicket(ticketId);
  //     emit(currentState.copyWith(
  //       conversations: conversations,
  //       currentConversationId: null,
  //       messages: [],
  //       isLoading: false,
  //     ));
  //     print('Successfully loaded ${conversations.length} conversations');
  //   } catch (e) {
  //     print('Error loading conversations: $e');
  //     emit(currentState.copyWith(
  //       error: 'Failed to load conversations: $e',
  //       isLoading: false,
  //     ));
  //   }
  // }

  // Future<void> loadMessages(String conversationId) async {
  //   print('Loading messages for conversation $conversationId');

  //   if (state is! ChatLoaded) {
  //     print('Current state is not ChatLoaded. Cannot load messages.');
  //     return;
  //   }

  //   final currentState = state as ChatLoaded;
  //   emit(currentState.copyWith(isLoading: true));

  //   try {
  //     await PusherService.subscribeToConversation(conversationId);
  //     final messages = await chatService.fetchMessages(conversationId);
  //     emit(currentState.copyWith(
  //       messages: messages,
  //       currentConversationId: conversationId,
  //       isLoading: false,
  //     ));
  //     print('Successfully loaded ${messages.length} messages');
  //   } catch (e) {
  //     print('Error loading messages: $e');
  //     emit(currentState.copyWith(
  //       error: 'Failed to load messages: $e',
  //       isLoading: false,
  //     ));
  //   }
  // }

  void _handlePusherEvent(PusherEvent event) {
    print('Handling Pusher event: ${event.eventName}');

    if (state is! ChatLoaded) {
      print('Current state is not ChatLoaded. Cannot handle Pusher event.');
      return;
    }

    final currentState = state as ChatLoaded;

    try {
      final data = jsonDecode(event.data);
      switch (event.eventName) {
        case 'new-message':
          _handleNewMessage(ChatMessage.fromJson(data));
          break;
        case 'message-deleted':
          _handleMessageDeleted(data['messageId'] as String);
          break;
        default:
          print('Unhandled Pusher event: ${event.eventName}');
      }
    } catch (e) {
      print('Error handling Pusher event: $e');
      emit(currentState.copyWith(
        error: 'Error handling Pusher event: $e',
      ));
    }
  }

  void _handleNewMessage(ChatMessage message) {
    print('Handling new message: ${message.id}');

    if (state is! ChatLoaded) {
      print('Current state is not ChatLoaded. Cannot handle new message.');
      return;
    }

    final currentState = state as ChatLoaded;

    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == message.conversationId) {
        return conv.copyWith(
          latestMessage: LatestMessage(
            id: message.id,
            senderId: int.parse(message.senderId),
            type: 0, // Assuming text message
            seen: false,
            createdAt: message.createdAt,
            content: message.text,
          ),
        );
      }
      return conv;
    }).toList();

    if (currentState.currentConversationId == message.conversationId) {
      emit(currentState.copyWith(
        conversations: updatedConversations,
        messages: [message, ...currentState.messages],
      ));
    } else {
      emit(currentState.copyWith(conversations: updatedConversations));
    }
  }

  void _handleMessageDeleted(String messageId) {
    print('Handling deleted message: $messageId');

    if (state is! ChatLoaded) {
      print('Current state is not ChatLoaded. Cannot handle message deletion.');
      return;
    }

    final currentState = state as ChatLoaded;

    emit(currentState.copyWith(
      messages: currentState.messages.where((msg) => msg.id != messageId).toList(),
    ));
  }

  // Future<void> sendMessage(String text) async {
  //   if (state is! ChatLoaded) {
  //     print('Current state is not ChatLoaded. Cannot send message.');
  //     return;
  //   }

  //   final currentState = state as ChatLoaded;

  //   if (currentState.currentConversationId == null) {
  //     print('No active conversation to send message');
  //     return;
  //   }

  //   print('Sending message: $text');
  //   final newMessage = ChatMessage(
  //     id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
  //     text: text,
  //     senderId: _currentUserId,
  //     conversationId: currentState.currentConversationId!,
  //     createdAt: DateTime.now(),
  //     isMe: true,
  //   );

  //   // Optimistic update
  //   emit(currentState.copyWith(
  //     messages: [newMessage, ...currentState.messages],
  //   ));

  //   try {
  //     await chatService.sendMessage(
  //       conversationId: currentState.currentConversationId!,
  //       text: text,
  //     );
  //     print('Message sent successfully');
  //   } catch (e) {
  //     print('Failed to send message: $e');
  //     // Revert on error
  //     emit(currentState.copyWith(
  //       messages: currentState.messages,
  //       error: 'Failed to send message: $e',
  //     ));
  //   }
  // }

  @override
  Future<void> close() async {
    print('Closing ChatCubit...');
    await PusherService.disconnect();
    return super.close();
  }
}

class ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> messages;
  final String? currentConversationId;
  final String currentUserId;
  final String? error;
  final bool isLoading;

  ChatState({
    required this.conversations,
    required this.messages,
    required this.currentUserId,
    this.currentConversationId,
    this.error,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    List<ChatMessage>? messages,
    String? currentConversationId,
    String? currentUserId,
    String? error,
    bool? isLoading,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      currentUserId: currentUserId ?? this.currentUserId,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatInitial extends ChatState {
  ChatInitial()
      : super(
          conversations: [],
          messages: [],
          currentUserId: '',
          isLoading: true,
        );
}

class ChatLoaded extends ChatState {
  ChatLoaded({
    required super.conversations,
    required super.messages,
    required super.currentUserId,
    super.currentConversationId,
    super.error,
    super.isLoading = false,
  });
}

