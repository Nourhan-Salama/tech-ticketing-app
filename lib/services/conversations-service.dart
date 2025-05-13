import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/conversation-model.dart';

class ConversationsService {
  static const String _baseUrl = 'https://graduation.arabic4u.org/api';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<Conversation>> fetchConversations() async {
    try {
      // Read token from secure storage
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        throw Exception('No access token found');
      }

      // Make the API call with proper headers
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) {
          return []; // Return empty list if no conversations
        }
        final List<dynamic> conversationsJson = data['data'];
        return conversationsJson
            .map((json) => Conversation.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      throw Exception('Failed to load conversations: $e');
    }
  }
}

