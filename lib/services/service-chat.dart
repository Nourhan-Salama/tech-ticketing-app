
import 'package:dio/dio.dart';
import 'package:tech_app/models/chat-model.dart';

class ChatService {
  final Dio dio = Dio();
Future<List<ChatModel>> fetchChats(String managerId) async {
  try {
    final response = await dio.get("https://yourapi.com/chats/$managerId");//Api Link 

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;

      List<ChatModel> chats = data
          .map((chat) => ChatModel.fromJson(chat))
          //.where((chat) => chat.messages.isNotEmpty)
          .toList();

      return chats;
    } else {
      throw Exception("Failed to load chats");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Error fetching chats");
  }
}}

