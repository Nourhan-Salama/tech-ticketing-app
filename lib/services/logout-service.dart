import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/services/pusher-service.dart';


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
      final token = await secureStorage.read(key: 'access_token');
      if (token == null) {
        await _cleanUpLocalAuth();
        return {'code': 401, 'message': 'No access token found'};
      }

      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      await _cleanUpLocalAuth();

      return {
        'code': response.statusCode,
        'message': response.statusCode == 200 
          ? 'Logout successful' 
          : 'Logged out locally (server logout failed)',
      };
    } catch (e) {
      await _cleanUpLocalAuth();
      return {
        'code': 500,
        'message': 'Logout error: ${e.toString()}',
      };
    }
  }

  Future<void> _cleanUpLocalAuth() async {
    // Disconnect Pusher first
    await PusherService.disconnect();
    
    // Then clear all local auth data
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'user_image_path');
  }
}