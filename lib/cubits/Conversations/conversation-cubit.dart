
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/Conversations/conversatins-state.dart';
import 'package:tech_app/models/conversation-model.dart';
import 'package:tech_app/services/conversations-service.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final ConversationsService _conversationsService;

  ConversationsCubit({ConversationsService? conversationsService})
      : _conversationsService = conversationsService ?? ConversationsService(),
        super(ConversationsInitial());

  Future<void> loadConversations() async {
    emit(ConversationsLoading());
    try {
      final conversations = await _conversationsService.fetchConversations();
      emit(ConversationsLoaded(
        allConversations: conversations,
        filteredConversations: conversations,
      ));
    } catch (e) {
      emit(ConversationsError('Failed to load conversations: ${e.toString()}'));
    }
  }

  void filterConversations(String query) {
    if (state is! ConversationsLoaded) return;
    final current = state as ConversationsLoaded;

    final filtered = current.allConversations.where((conv) {
      final name = conv.otherUser?.name?.toLowerCase() ?? '';
      final ticketId = conv.ticketId?.toString() ?? '';
      return name.contains(query.toLowerCase()) ||
          ticketId.contains(query.toLowerCase());
    }).toList();

    emit(current.copyWith(filteredConversations: filtered));
  }

   Future<Conversation?> getOrCreateConversationWithUser(int userId) async {
    try {
      emit(ConversationsLoading());
      final conversation = await _conversationsService.getOrCreateConversation(userId);
      
      if (conversation != null) {
        _emitLoadedWithConversation(conversation);
        return conversation;
      }
      
      throw Exception('Failed to get or create conversation');
    } catch (e) {
      emit(ConversationsError(e.toString()));
      return null;
    }
  }

  void _emitLoadedWithConversation(Conversation conversation) {
    emit(ConversationsLoaded(
      allConversations: [conversation],
      filteredConversations: [conversation],
    ));
  }

  void _emitLoadedStateWithConversation(Conversation conversation) {
    emit(ConversationsLoaded(
      allConversations: [conversation],
      filteredConversations: [conversation],
    ));
  }

  void addConversationToState(Conversation conversation) {
    if (state is! ConversationsLoaded) return;
    final current = state as ConversationsLoaded;

    final updatedAll = [conversation, ...current.allConversations];
    final updatedFiltered = [conversation, ...current.filteredConversations];

    emit(current.copyWith(
      allConversations: updatedAll,
      filteredConversations: updatedFiltered,
    ));
  }
}

