import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/Conversations/conversatins-state.dart';
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
      // Consider adding logic to handle token expiration here
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
}