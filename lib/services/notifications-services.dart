import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/models/notifications-model.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static const String _baseUrl = 'https://graduation.arabic4u.org';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  Future<String> get _accessToken async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception('No access token found');
    return token;
  }

  Future<Map<String, String>> get _headers async {
    return {
      'Authorization': 'Bearer ${await _accessToken}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  Future<void> _handleUnauthorized() async {
    await handleTokenRefresh();
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in getAllNotifications: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread_notifications_count'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['unreadNotificationsCount'] ?? 0;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in getUnreadCount: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in markAsRead: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in markAllAsRead: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in deleteNotification: $e');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error in deleteAllNotifications: $e');
      rethrow;
    }
  }

  Future<void> handleTokenRefresh() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) throw Exception('No refresh token available');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $refreshToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await _storage.deleteAll();
      throw Exception('Session expired. Please login again.');
    }
  }
    Future<void> updateFcmToken(String fcmToken) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/fcm_token'),
        headers: await _headers,
        body: json.encode({'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('FCM token updated: ${data['message']}');
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        return updateFcmToken(fcmToken); // Retry after refreshing token
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error updating FCM Token: $e');
      rethrow;
    }
  }

  Exception _handleError(http.Response response) {
    final errorData = json.decode(response.body);
    return Exception(errorData['message'] ?? 'Request failed with status ${response.statusCode}');
  }
}

