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
      emit(ConversationsError(e.toString()));
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
      Conversation? existingConversation =
          await _conversationsService.getConversationWithUser(userId);

      if (existingConversation != null) {
        return existingConversation;
      }

      Conversation newConversation =
          await _conversationsService.createConversationWithUser(userId);

      
      addConversationToState(newConversation);

      return newConversation;
    } catch (e) {
      print('Error in getOrCreateConversationWithUser: $e');
      return null;
    }
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

