import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogoutService {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  LogoutService({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : client = client ?? http.Client(),
        secureStorage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> logout() async {
    try {
      // First verify token exists before logout
      final tokenBeforeLogout = await secureStorage.read(key: 'access_token');
      if (tokenBeforeLogout == null) {
        return {
          'code': 401,
          'message': 'No access token found',
        };
      }

      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $tokenBeforeLogout',
          'Content-Type': 'application/json',
        },
      );

      // Always delete tokens regardless of server response
      await _clearAllTokens();

      // Verify tokens are actually deleted
      final tokenAfterDelete = await secureStorage.read(key: 'access_token');
      final refreshTokenAfterDelete = await secureStorage.read(key: 'refresh_token');

      if (tokenAfterDelete != null || refreshTokenAfterDelete != null) {
        return {
          'code': 500,
          'message': 'Logout failed: Tokens not properly deleted',
        };
      }

      if (response.statusCode == 200) {
        return {
          'code': 200,
          'message': 'Logout successful',
        };
      } else {
        // Even if the server logout fails, we've deleted the tokens locally
        return {
          'code': 200,
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      // Try to delete tokens even if there was an error
      await _clearAllTokens();
      
      return {
        'code': 500,
        'message': 'Logout error: ${e.toString()}',
      };
    }
  }

  Future<void> _clearAllTokens() async {
    // Delete all auth-related data
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_image_path');
  }
}