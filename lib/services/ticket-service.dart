
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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
}


// import 'dart:convert';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:tech_app/models/ticket-details-model.dart';
// import 'package:tech_app/models/ticket-model.dart';

// class TicketService {
//   final String baseUrl = 'https://graduation.arabic4u.org/api/technicians/tickets';
//   final FlutterSecureStorage _storage = FlutterSecureStorage();

//   Future<String?> _getToken() async {
//     return await _storage.read(key: 'access_token');
//   }

//   Future<Map<String, dynamic>> createTicket({
  
//     required String description,
//     required String title,
//     required String serviceId,
//   }) async {
//     final token = await _getToken();
//     final url = Uri.parse(baseUrl);

//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
        
//         'description': description,
//         'title': title,
//         'service_id': serviceId,
//       },
//     );

//     final json = jsonDecode(response.body);
//     if (response.statusCode == 201) {
//       return {
//         'success': true,
//         'data': json['data'],
//         'message': json['message'],
//       };
//     } else if (response.statusCode == 422) {
//       return {
//         'success': false,
//         'message': json['message'] ?? 'Validation error',
//       };
//     } else {
//       return {
//         'success': false,
//         'message': json['message'] ?? 'Something went wrong',
//       };
//     }
//   }
//    // Add this method to your TicketService class
//   Future<Map<String, dynamic>> getPaginatedTickets(int page) async {
//     final token = await _getToken();
//     final url = Uri.parse('$baseUrl?page=$page');

//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       return {
//         'tickets': (json['data'] as List).map((t) => TicketModel.fromJson(t)).toList(),
//         'current_page': json['meta']['current_page'],
//         'last_page': json['meta']['last_page'],
//         'total': json['meta']['total'],
//       };
//     } else {
//       throw Exception('Failed to load tickets: ${response.statusCode}');
//     }
//   }
//    Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
//   final token = await _getToken();
//   final url = Uri.parse('$baseUrl/$ticketId');

//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body);
//     return TicketDetailsModel.fromJson(json['data']);
//   } else {
//     throw Exception('Failed to load ticket details: ${response.statusCode}');
//   }
// }

// }

// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:tech_app/models/ticket-details-model.dart';
// import 'package:tech_app/models/ticket-model.dart';

// class TicketResponse {
//   final List<TicketModel> tickets;
//   final int currentPage;
//   final int lastPage;
//   final int total;

//   TicketResponse({
//     required this.tickets,
//     required this.currentPage,
//     required this.lastPage,
//     required this.total,
//   });
// }

// class TechnicianTicketService {
//   static const String _baseUrl = 'https://graduation.arabic4u.org';
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Helper methods
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final token = await _storage.read(key: 'access_token');
//     if (token == null) {
//       throw Exception('Access token not found');
//     }
//     return {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<dynamic> _handleResponse(http.Response response) {
//     final statusCode = response.statusCode;
//     final responseBody = json.decode(response.body);

//     print('API Response [$statusCode]: ${response.body}');

//     if (statusCode >= 200 && statusCode < 300) {
//       return responseBody;
//     } else {
//       final errorMessage = responseBody['message'] ?? 'Request failed with status $statusCode';
//       throw Exception(errorMessage);
//     }
//   }

//   // Ticket operations
//   Future<TicketResponse> getTechnicianTickets({int page = 1}) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$_baseUrl/api/technicians/tickets?page=$page');

//       final response = await http.get(url, headers: headers);
//       final jsonData = await _handleResponse(response);

//       final tickets = (jsonData['data'] as List)
//           .map((e) => TicketModel.fromJson(e))
//           .toList();

//       return TicketResponse(
//         tickets: tickets,
//         currentPage: jsonData['meta']['current_page'] ?? 1,
//         lastPage: jsonData['meta']['last_page'] ?? 1,
//         total: jsonData['meta']['total'] ?? 0,
//       );
//     } catch (e) {
//       print('Error in getTechnicianTickets: $e');
//       rethrow;
//     }
//   }

//   Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$_baseUrl/api/technicians/tickets/$ticketId');

//       final response = await http.get(url, headers: headers);
//       final jsonData = await _handleResponse(response);

//       return TicketDetailsModel.fromJson(jsonData['data']);
//     } catch (e) {
//       print('Error in getTicketDetails: $e');
//       rethrow;
//     }
//   }

//   Future<void> finishTicket(int ticketId) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$_baseUrl/api/technicians/tickets/$ticketId/finish');

//       final response = await http.post(url, headers: headers);
//       await _handleResponse(response);
//     } catch (e) {
//       print('Error in finishTicket: $e');
//       rethrow;
//     }
//   }
// }

