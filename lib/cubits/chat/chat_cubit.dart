import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/chat/chat_state.dart';
import 'package:tech_app/services/chat_service.dart';
import 'package:tech_app/models/chat_message.dart' as chat;

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;
  
  ChatCubit({ChatService? chatService})
      : _chatService = chatService ?? ChatService(),
        super(ChatInitial());

  void initializeChat(String ticketId) async {
    emit(ChatLoading());
    try {
      await _chatService.initializePusher();
      await _chatService.subscribeToTicketChannel(ticketId, _handleIncomingMessage);
      emit(const ChatLoaded(messages: []));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _handleIncomingMessage(dynamic data) {
    if (state is ChatLoaded && data != null) {
      final currentState = state as ChatLoaded;
      final message = chat.ChatMessage.fromJson(data as Map<String, dynamic>);

      if (message.isTyping) {
        emit(currentState.copyWith(isTyping: true));
        Future.delayed(const Duration(seconds: 3), () {
          if (state is ChatLoaded) {
            emit((state as ChatLoaded).copyWith(isTyping: false));
          }
        });
        return;
      }

      final messages = List<chat.ChatMessage>.from(currentState.messages);
      messages.insert(0, message);
      emit(currentState.copyWith(messages: messages));
    }
  }

  void sendMessage(String ticketId, chat.ChatMessage message) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final messages = List<chat.ChatMessage>.from(currentState.messages);
      messages.insert(0, message);
      emit(currentState.copyWith(messages: messages));

      try {
        await _chatService.sendMessage(ticketId, message.toJson());
      } catch (e) {
        // Handle error but keep the message in the list
        emit(ChatError(e.toString()));
        emit(currentState); // Revert to previous state
      }
    }
  }

  void dispose(String ticketId) async {
    await _chatService.unsubscribeFromTicketChannel(ticketId);
    await _chatService.disconnect();
  }
} 