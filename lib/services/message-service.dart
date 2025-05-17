import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/chat_message.dart';

class MessagesService {
  static const String _baseUrl = 'https://graduation.arabic4u.org/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? ticketId,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No access token found');

      final response = await http.post(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: _headers(token),
        body: json.encode({
          'content': content,
          'type': type.value,
          'ticket_id': ticketId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatMessage.fromJson(data['data']);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in sendMessage: $e');
      rethrow;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) throw Exception('No access token found');

      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data['data'] ?? [];
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchMessages: $e');
      rethrow;
    }
  }

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}