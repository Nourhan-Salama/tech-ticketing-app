import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tech_app/models/ticket-details-model.dart';
import 'package:tech_app/models/ticket-model.dart';

class TicketService {
  static const String _baseUrl = 'https://graduation.arabic4u.org';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('Access token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> getPaginatedTickets(int page) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$_baseUrl/api/technicians/tickets?page=$page');
      
      print('🌐 Fetching tickets from: $url');
      final response = await http.get(url, headers: headers);
      print('🔵 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Received ${jsonData['data']?.length ?? 0} tickets');
        
        final tickets = (jsonData['data'] as List)
            .map((e) => TicketModel.fromJson(e))
            .toList();

        return {
          'tickets': tickets,
          'current_page': jsonData['meta']['current_page'] ?? 1,
          'last_page': jsonData['meta']['last_page'] ?? 1,
          'total': jsonData['meta']['total'] ?? 0,
        };
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getPaginatedTickets: $e');
      rethrow;
    }
  }

  Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$_baseUrl/api/technicians/tickets/$ticketId');
      
      print('🌐 Fetching ticket details from: $url');
      final response = await http.get(url, headers: headers);
      print('🔵 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📦 Received ticket details for ID: $ticketId');
        return TicketDetailsModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load ticket details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getTicketDetails: $e');
      rethrow;
    }
  }
}

