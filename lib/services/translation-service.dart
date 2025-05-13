import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TranslationApiService {
  static const _baseUrl = 'https://graduation.arabic4u.org/api';
  final _storage = const FlutterSecureStorage();

  Future<bool> updateLocale(String locale) async {
    try {
      final token = await _storage.read(key: 'access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/update_locale?locale=$locale'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Language updated successfully on server');
        return true;
      } else {
        print('Failed to update locale: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating locale: $e');
      return false;
    }
  }
}
