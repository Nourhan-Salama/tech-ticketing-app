import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalizationService {
  static const String _baseUrl = 'https://graduation.arabic4u.org';

  // Secure storage instance to get the token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> updateLocale(String locale) async {
    final String endpoint = '/auth/update_locale';
    final Uri url = Uri.parse('$_baseUrl$endpoint?locale=$locale');

    try {
      // Get the stored token
      final String? token = await _secureStorage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Access token not found.');
      }

      // Send the PATCH request with Authorization header
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['code'] == 200 && data['type'] == 'success') {
          print('Locale updated successfully');
          // يمكنك هنا إضافة Snackbar أو Toast
        } else {
          throw Exception(data['message'] ?? 'Unknown error');
        }
      } else {
        // Handle error response
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update locale: $e');
      throw Exception('Failed to update locale: $e');
    }
  }
}

