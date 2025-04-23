import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/models/chat-model.dart';
import 'package:tech_app/services/service-chat.dart';


class ChatCubit extends Cubit<List<ChatModel>> {
  final ChatService chatService;

  ChatCubit(this.chatService) : super([]);

  /// Fetch Chats with Error Handling
  Future<void> fetchChats(String userId) async {
    try {
      /// Show Loading State
      emit([]);

      /// Fetch Chats from API
      final chats = await chatService.fetchChats(userId);

      /// Update State with New Chats
      emit(chats);
    } catch (e, stackTrace) {
      /// Log the Error & Stack Trace for Debugging
      print(" Error fetching chats: $e");
      print(" Stack trace: $stackTrace");

      /// Emit an empty list or show an error state (optional)
      emit([]);
    }
  }
}

