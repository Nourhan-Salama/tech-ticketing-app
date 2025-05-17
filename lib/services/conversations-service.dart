import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/conversation-model.dart';

class ConversationsService {
  static const String _baseUrl = 'https://graduation.arabic4u.org/api';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<Conversation>> fetchConversations() async {
    try {
      final token = await _getToken();

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
      rethrow;
    }
  }

  Future<Conversation?> getOrCreateConversation(int userId) async {
    try {
      final existing = await getConversationWithUser(userId);
      if (existing != null) return existing;

      return await createConversationWithUser(userId);
    } catch (e) {
      print('❌ Error in getOrCreateConversation: $e');
      rethrow;
    }
  }

  Future<Conversation?> getConversationWithUser(int userId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/for?user_id=$userId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return null;
        return Conversation.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getConversationWithUser: $e');
      rethrow;
    }
  }

  Future<Conversation> createConversationWithUser(int userId) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: _headers(token),
        body: json.encode({
          'type': 0,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['data'] == null) throw Exception('No conversation data');
        return Conversation.fromJson(data['data']);
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createConversationWithUser: $e');
      rethrow;
    }
  }

  /// ✅ Store conversation (create it on the backend)
  Future<Conversation> storeConversation(int userId) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: _headers(token),
        body: json.encode({
          'type': 0,       // Private conversation
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['data'] == null) throw Exception('No conversation returned');
        return Conversation.fromJson(data['data']);
      } else {
        throw Exception('Failed to store conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in storeConversation: $e');
      rethrow;
    }
  }

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token == null) throw Exception('No access token found');
    return token;
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}


