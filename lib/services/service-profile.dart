import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  final http.Client client;
  final FlutterSecureStorage secureStorage;
  final String baseUrl;

  ProfileService({
    required this.client,
    required this.secureStorage,
    this.baseUrl = "https://graduation.arabic4u.org",
  });

  Future<String?> _getAccessToken() async {
    try {
      return await secureStorage.read(key: 'access_token');
    } catch (e) {
      throw Exception('Failed to retrieve access token: $e');
    }
  }

  // Get profile from API
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData['data'] ?? {};
      } else {
        throw Exception('Failed to load profile: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  // Save image path consistently using the same key
  Future<void> saveImagePath(String path) async {
    await secureStorage.write(key: 'user_image_path', value: path);
  }

  // Remove user image path from storage
  Future<void> removeUserImage() async {
    await secureStorage.delete(key: 'user_image_path');
  }

  // Update profile with name and optional avatar
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    File? avatar,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/profile'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = '$firstName $lastName';

      if (avatar != null && avatar.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // If successful, save the image path locally
        if (avatar != null) {
          await saveImagePath(avatar.path);
        }
        return responseData['data'] ?? {};
      } else {
        throw Exception('Update failed: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Save user data in secure storage
  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    String? imagePath,
  }) async {
    await secureStorage.write(key: 'user_name', value: '$firstName $lastName');
    if (imagePath != null) {
      await secureStorage.write(key: 'user_image_path', value: imagePath);
    }
  }

  // Load saved user data
  Future<Map<String, String?>> loadUserData() async {
    return {
      'name': await secureStorage.read(key: 'user_name'),
      'image_path': await secureStorage.read(key: 'user_image_path'),
    };
  }

  // Clear local user data
  Future<void> clearUserData() async {
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_image_path');
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ProfileService {
//   final http.Client client;
//   final FlutterSecureStorage secureStorage;
//   final String baseUrl;

//   ProfileService({
//     required this.client,
//     required this.secureStorage,
//     this.baseUrl = "https://graduation.arabic4u.org",
//   });

//   Future<String?> _getAccessToken() async {
//     try {
//       return await secureStorage.read(key: 'access_token');
//     } catch (e) {
//       throw Exception('Failed to retrieve access token: $e');
//     }
//   }

//   // Get profile from API
//   Future<Map<String, dynamic>> getProfile() async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception('User not authenticated');

//     try {
//       final response = await client.get(
//         Uri.parse('$baseUrl/auth/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 30));

//       final responseData = json.decode(response.body);
//       if (response.statusCode == 200) {
//         return responseData['data'] ?? {};
//       } else {
//         throw Exception('Failed to load profile: ${responseData['message']}');
//       }
//     } catch (e) {
//       throw Exception('Error loading profile: $e');
//     }
//   }

//   Future<void> saveImagePath(String path) async {
//     final storage = const FlutterSecureStorage();
//     await storage.write(key: 'image_path', value: path);
//   }

//   Future<void> removeUserImage() async {
//     final storage = FlutterSecureStorage();
//     await storage.delete(key: 'imagePath');
//   }

//   // Update profile with name, email, and optional avatar
//   Future<Map<String, dynamic>> updateProfile({
//     required String firstName,
//     required String lastName,
//     //required String email,
//     File? avatar,
//   }) async {
//     final token = await _getAccessToken();
//     if (token == null) throw Exception('User not authenticated');

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/auth/profile'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';
//       request.fields['name'] = '$firstName $lastName';
//       //request.fields['email'] = email;

//       if (avatar != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'avatar',
//             avatar.path,
//             filename: avatar.path.split('/').last,
//           ),
//         );
//       }

//       final response = await request.send();
//       final responseString = await response.stream.bytesToString();
//       final responseData = json.decode(responseString);

//       if (response.statusCode == 200) {
//         return responseData['data'] ?? {};
//       } else {
//         throw Exception('Update failed: ${responseData['message']}');
//       }
//     } catch (e) {
//       throw Exception('Error updating profile: $e');
//     }
//   }

//   // Save user data in secure storage
//   Future<void> saveUserData({
//     required String firstName,
//     required String lastName,
//    // required String email,
//     String? imagePath,
//   }) async {
//     await secureStorage.write(key: 'user_name', value: '$firstName $lastName');
//    // await secureStorage.write(key: 'user_email', value: email);
//     if (imagePath != null) {
//       await secureStorage.write(key: 'user_image_path', value: imagePath);
//     }
//   }

//   // Load saved user data
//   Future<Map<String, String?>> loadUserData() async {
//     return {
//       'name': await secureStorage.read(key: 'user_name'),
//      // 'email': await secureStorage.read(key: 'user_email'),
//       'image_path': await secureStorage.read(key: 'user_image_path'),
//     };
//   }

//   // Clear local user data
//   Future<void> clearUserData() async {
//     await secureStorage.delete(key: 'user_name');
//    // await secureStorage.delete(key: 'user_email');
//     await secureStorage.delete(key: 'user_image_path');
//   }
// }
