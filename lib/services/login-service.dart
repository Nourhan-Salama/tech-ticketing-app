import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tech_app/services/pusher-service.dart';


class AuthService {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  AuthService({
    this.baseUrl = "https://graduation.arabic4u.org",
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : client = client ?? http.Client(),
        secureStorage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
  required String handle,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/auth/login');

  try {
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': handle, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['data'] == null) {
        throw Exception("No data in response");
      }

      final data = responseData['data'];
      final userId = data['user']['id'].toString();

      // Save tokens and user data
      await _saveAuthData(
        token: data['token'],
        refreshToken: data['refresh_token'],
        userId: userId,
        name: data['user']['name'],
        email: data['user']['email'],
      );

      // Initialize Pusher with userId
      final pusherService = PusherService();
      await PusherService.initPusher(userId: userId);

      return {
        'code': 200,
        'message': responseData['message'],
        'data': {
          'token': data['token'],
          'refresh_token': data['refresh_token'],
          'user': data['user'],
        },
      };
    } else {
      return _handleError(response);
    }
  } catch (e) {
    print('Login error: $e');
    return {
      'code': 500,
      'message': 'Network error occurred: ${e.toString()}',
      'error': e.toString(),
    };
  }
}


  Future<void> _saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await secureStorage.write(key: 'access_token', value: token);
      await secureStorage.write(key: 'refresh_token', value: refreshToken);
      await secureStorage.write(key: 'user_id', value: userId);
      await secureStorage.write(key: 'user_name', value: name);
      await secureStorage.write(key: 'user_email', value: email);
    } catch (e) {
      print('Error saving auth data: $e');
      throw Exception('Failed to save authentication data');
    }
  }
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      await secureStorage.write(key: 'access_token', value: accessToken);
      await secureStorage.write(key: 'refresh_token', value: refreshToken);
      print('Tokens saved successfully');
    } catch (e) {
      print('Error saving tokens: $e');
      throw Exception('Failed to save tokens');
    }
  }

  Future<void> _saveUserInfo(String name, String email) async {
    try {
      await secureStorage.write(
          key: 'user_name', value: name); 
      await secureStorage.write(
          key: 'user_email', value: email); 
      print('User info saved successfully');
    } catch (e) {
      print('Error saving user info: $e');
      throw Exception('Failed to save user info');
    }
  }

  Future<String?> getUserName() async {
    try {
      return await secureStorage.read(key: 'user_name');
    } catch (e) {
      print('Error reading user name: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await secureStorage.read(key: 'user_email');
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      return await secureStorage.read(key: 'access_token');
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<String?> _getRefreshToken() async {
    try {
      return await secureStorage.read(key: 'refresh_token');
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getProtectedData(String endpoint) async {
    try {
      String? token = await _getAccessToken();
      if (token == null) {
        return {'code': 401, 'message': 'No access token found'};
      }

      final response = await client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        bool refreshed = await _refreshAccessToken();
        if (refreshed) {
          return getProtectedData(endpoint); // Retry request
        } else {
          return {
            'code': 401,
            'message': 'Session expired. Please login again.'
          };
        }
      }

      return {
        'code': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'code': 500,
        'message': 'Error fetching protected data: ${e.toString()}',
      };
    }
  }

  Future<bool> _refreshAccessToken() async {
    try {
      String? refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await client.post(
        Uri.parse('$baseUrl/auth/refresh_tokens/rotate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _saveTokens(responseData['data']['token'], refreshToken);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      return {
        'code': response.statusCode,
        'message': responseData['message'] ?? 'Unknown error',
      };
    } catch (e) {
      return {
        'code': response.statusCode,
        'message': 'Failed to parse error response',
      };
    }
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthApi {
//   final String baseUrl;
//   final http.Client client;
//   final FlutterSecureStorage secureStorage;

//   AuthApi({
//     this.baseUrl = "https://graduation.arabic4u.org",
//     http.Client? client,
//     FlutterSecureStorage? storage,
//   })  : client = client ?? http.Client(),
//         secureStorage = storage ?? const FlutterSecureStorage();

//   Future<Map<String, dynamic>> login({
//     required String handle,
//     required String password,
//   }) async {
//     final url = Uri.parse('$baseUrl/auth/login');

//     try {
//       final response = await client.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': handle, 'password': password}),
//       );

//       final responseData = jsonDecode(response.body);

//       print('API Response: $responseData');

//       if (response.statusCode == 200) {
//         if (responseData['data'] == null) {
//           throw Exception("No data in response");
//         }

//         final data = responseData['data'];

//         // Save tokens
//         await _saveTokens(data['token'], data['refresh_token']);

//         // Save user info
//         await _saveUserInfo(
//           data['user']['name'],
//           data['user']['email'],
//         );

//         return {
//           'code': 200,
//           'message': responseData['message'],
//           'data': {
//             'token': data['token'],
//             'refresh_token': data['refresh_token'],
//             'user': {
//               'id': data['user']['id'],
//               'name': data['user']['name'],
//               'email': data['user']['email'],
//               'phone': data['user']['phone'] ?? '',
//               'avatar': data['user']['avatar'],
//               'type': data['user']['type'],
//               'last_login': data['user']['last_login_time'],
//               'status': data['user']['status'],
//             },
//           },
//         };
//       } else {
//         return _handleError(response);
//       }
//     } catch (e) {
//       print('Login error: $e');
//       return {
//         'code': 500,
//         'message': 'Network error occurred: ${e.toString()}',
//         'error': e.toString(),
//       };
//     }
//   }

//   Future<void> _saveTokens(String accessToken, String refreshToken) async {
//     try {
//       await secureStorage.write(key: 'access_token', value: accessToken);
//       await secureStorage.write(key: 'refresh_token', value: refreshToken);
//       print('Tokens saved successfully');
//     } catch (e) {
//       print('Error saving tokens: $e');
//       throw Exception('Failed to save tokens');
//     }
//   }

// // auth-api.dart (updated)
//   Future<void> _saveUserInfo(String name, String email) async {
//     try {
//       await secureStorage.write(
//           key: 'user_name', value: name); // Changed from 'name'
//       await secureStorage.write(
//           key: 'user_email', value: email); // Changed from 'email'
//       print('User info saved successfully');
//     } catch (e) {
//       print('Error saving user info: $e');
//       throw Exception('Failed to save user info');
//     }
//   }

//   Future<String?> getUserName() async {
//     try {
//       return await secureStorage.read(key: 'user_name');
//     } catch (e) {
//       print('Error reading user name: $e');
//       return null;
//     }
//   }

//   Future<String?> getUserEmail() async {
//     try {
//       return await secureStorage.read(key: 'user_email');
//     } catch (e) {
//       print('Error reading user email: $e');
//       return null;
//     }
//   }

//   Future<String?> _getAccessToken() async {
//     try {
//       return await secureStorage.read(key: 'access_token');
//     } catch (e) {
//       print('Error getting access token: $e');
//       return null;
//     }
//   }

//   Future<String?> _getRefreshToken() async {
//     try {
//       return await secureStorage.read(key: 'refresh_token');
//     } catch (e) {
//       print('Error getting refresh token: $e');
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>> getProtectedData(String endpoint) async {
//     try {
//       String? token = await _getAccessToken();
//       if (token == null) {
//         return {'code': 401, 'message': 'No access token found'};
//       }

//       final response = await client.get(
//         Uri.parse('$baseUrl/$endpoint'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 401) {
//         bool refreshed = await _refreshAccessToken();
//         if (refreshed) {
//           return getProtectedData(endpoint); // Retry request
//         } else {
//           return {
//             'code': 401,
//             'message': 'Session expired. Please login again.'
//           };
//         }
//       }

//       return {
//         'code': response.statusCode,
//         'data': jsonDecode(response.body),
//       };
//     } catch (e) {
//       return {
//         'code': 500,
//         'message': 'Error fetching protected data: ${e.toString()}',
//       };
//     }
//   }

//   Future<bool> _refreshAccessToken() async {
//     try {
//       String? refreshToken = await _getRefreshToken();
//       if (refreshToken == null) return false;

//       final response = await client.post(
//         Uri.parse('$baseUrl/auth/refresh_tokens/rotate'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refresh_token': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         await _saveTokens(responseData['data']['token'], refreshToken);
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('Error refreshing token: $e');
//       return false;
//     }
//   }

//   Map<String, dynamic> _handleError(http.Response response) {
//     try {
//       final responseData = jsonDecode(response.body);
//       return {
//         'code': response.statusCode,
//         'message': responseData['message'] ?? 'Unknown error',
//       };
//     } catch (e) {
//       return {
//         'code': response.statusCode,
//         'message': 'Failed to parse error response',
//       };
//     }
//   }
// }
