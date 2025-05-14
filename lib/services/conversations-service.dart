import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/conversation-model.dart';

class ConversationsService {
  static const String _baseUrl = 'https://graduation.arabic4u.org/api';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // ✅ Get all conversations
  Future<List<Conversation>> fetchConversations() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No access token found');

      final response = await http.get(
        Uri.parse('$_baseUrl/conversations'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> conversationsJson = data['data'] ?? [];
        return conversationsJson
            .map((json) => Conversation.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchConversations: $e');
      throw Exception('Failed to load conversations: $e');
    }
  }

  // ✅ Get specific conversation with a user
  Future<Conversation?> getConversationWithUser(int userId) async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No access token found');

      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/for?user_id=$userId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return null;
        return Conversation.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getConversationWithUser: $e');
      throw Exception('Failed to fetch conversation: $e');
    }
  }

  // ✅ Create a new conversation with a user (type = 0)
  Future<Conversation> createConversationWithUser(int userId) async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No access token found');

      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: _headers(token),
        body: json.encode({
          'type': 0, // Private conversation
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['data'] == null) {
          throw Exception('Unexpected response format');
        }
        return Conversation.fromJson(data['data']);
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createConversationWithUser: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }
  Future<void> sendMessage({
  required String conversationId,
  required String content,
  required int type, // 0 for text, 1 for image, etc.
}) async {
  try {
    String? token = await _secureStorage.read(key: 'access_token');
    if (token == null) throw Exception('No access token found');

    final response = await http.post(
      Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
      headers: _headers(token),
      body: json.encode({
        'content': content,
        'type': type,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error in sendMessage: $e');
    throw Exception('Failed to send message: $e');
  }
}

  // 🔐 Shared headers
  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}



