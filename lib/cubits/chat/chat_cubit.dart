// messages_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/chat/chat_state.dart';
import 'package:tech_app/models/chat_message.dart';
import 'package:tech_app/services/message-service.dart';



class MessagesCubit extends Cubit<MessagesState> {
  final MessagesService _messagesService;

  MessagesCubit({required MessagesService messagesService})
      : _messagesService = messagesService,
        super(MessagesInitial());

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? ticketId,
  }) async {
    try {
      emit(MessageSending());

      final message = await _messagesService.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        ticketId: ticketId,
      );

      emit(MessageSentSuccess(message));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      emit(MessagesLoading());

      final messages = await _messagesService.fetchMessages(conversationId);

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}