
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/statistics-model.dart';

class StatisticsService {
  static const String _baseUrl = 'https://graduation.arabic4u.org';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<StatisticsModel> getTechnicianStatistics() async {
    try {
      print('🔍 Step 1: Reading token from Secure Storage...');
      final token = await _storage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        print('❌ Token is null or empty');
        throw Exception('No authentication token found');
      }
      print('✅ Token retrieved: ${token.substring(0, 20)}...');

      final url = Uri.parse('$_baseUrl/api/technicians/statistics');
      print('🌐 Request URL: $url');

      print('📤 Sending GET request with token...');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        print('✅ API call succeeded');
        print('📦 Full Response Data:');
        responseData.forEach((key, value) {
          print('  ➤ $key: $value');
        });

        if (responseData['data'] == null) {
          print('⚠️ Data field is null');
          throw Exception('API returned null data');
        }

        try {
          final model = StatisticsModel.fromJson(responseData['data']);
          print('✅ Statistics model parsed successfully');
          return model;
        } catch (e) {
          print('❌ Error parsing statistics model: $e');
          print('🧪 Raw data that caused issue: ${responseData['data']}');
          throw Exception('Failed to parse statistics data');
        }

      } else if (response.statusCode == 403) {
        print('❌ Access Denied (403): Check token validity or user permissions');
        final errorResponse = json.decode(response.body);
        print('🔒 Error Message: ${errorResponse['message']}');
        throw Exception('Access Denied: ${errorResponse['message']}');
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to load statistics');
      }

    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Network error occurred');
    } on TimeoutException catch (e) {
      print('⏱ Request timeout: $e');
      throw Exception('Request timed out');
    } catch (e) {
      print('❗ Unexpected error: $e');
      rethrow;
    }
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:tech_app/models/statistics-model.dart';

// class StatisticsService {
//   static const String _baseUrl = 'https://graduation.arabic4u.org';
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<StatisticsModel> getTechnicianStatistics() async {
//     try {
//       final token = await _storage.read(key: 'access_token');
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }

//       final url = Uri.parse('$_baseUrl/api/technicians/statistics');
//       print('Request URL: $url');
//       print('Using token: ${token.substring(0, 10)}...'); // Log partial token for security

//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 30));

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
        
//         // Debug print the complete response structure
//         print('Complete Response Structure:');
//         responseData.forEach((key, value) {
//           print('$key: $value');
//         });

//         if (responseData['data'] == null) {
//           throw Exception('API returned null data');
//         }

//         try {
//           return StatisticsModel.fromJson(responseData['data']);
//         } catch (e) {
//           print('Error parsing model: $e');
//           print('Problematic data: ${responseData['data']}');
//           throw Exception('Failed to parse statistics data');
//         }
//       } else {
//         final errorResponse = json.decode(response.body);
//         throw Exception(errorResponse['message'] ?? 'Failed to load statistics');
//       }
//     } on http.ClientException catch (e) {
//       print('Network error: $e');
//       throw Exception('Network error occurred');
//     } on TimeoutException catch (e) {
//       print('Request timeout: $e');
//       throw Exception('Request timed out');
//     } catch (e) {
//       print('Unexpected error: $e');
//       rethrow;
//     }
//   }
// }

