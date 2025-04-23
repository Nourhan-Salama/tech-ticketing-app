import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tech_app/Helper/enum-helper.dart';


class VerifyUserApi {
  final String baseUrl = "https://graduation.arabic4u.org";

  Future<Map<String, dynamic>> verifyUser({
    required String handle,
    required String code,
    required OtpType otpType,
  }) async {
    final endpoint = otpType == OtpType.verification
        ? '/auth/verify_user'
        : '/auth/password/validate_code';
    
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      print("🔹 Sending request to: $url");
      print("📩 Request Body: ${jsonEncode({"handle": handle, "code": code})}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "handle": handle,
          "code": code,
        }),
      );

      print("📬 Response Code: ${response.statusCode}");
      print("📜 Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);
      final int statusCode = response.statusCode;

      if (statusCode == 200 && responseData["type"] == "success") {
        print("✅ OTP verification successful.");
        return {
          "success": true,
          "message": responseData["message"] ?? 
            (otpType == OtpType.verification 
              ? "Account verified successfully!" 
              : "OTP verified successfully!"),
          "data": responseData["data"],
          "showToast": responseData["showToast"] ?? false,
        };
      } else if (statusCode == 422) {
        final errors = responseData["data"] ?? {};
        if (errors.containsKey("handle")) {
          print("❌ Error: Handle does not exist.");
          return {
            "success": false,
            "message": "Handle does not exist.",
            "errors": errors,
          };
        } else if (errors.containsKey("user_already_verified")) {
          print("❌ Error: User already verified.");
          return {
            "success": false,
            "message": "You have already verified your account before.",
            "errors": errors,
          };
        }
        print("⚠️ Validation error occurred.");
        return {
          "success": false,
          "message": responseData["message"] ?? "Validation error.",
          "errors": errors,
        };
      } else if (statusCode == 404) {
        print("❌ Error: User not found.");
        return {
          "success": false,
          "message": "User not found, please check your email.",
        };
      } else {
        print("⚠️ Unknown error occurred.");
        return {
          "success": false,
          "message": responseData["message"] ?? "Something went wrong.",
        };
      }
    } catch (error) {
      print("🚨 Request Error: $error");
      return {
        "success": false,
        "message": "Failed to verify OTP: $error",
      };
    }
  }
}
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class VerifyUserApi {
  
//   final String baseUrl = "https://graduation.arabic4u.org";

//   Future<Map<String, dynamic>> verifyUser({
//     required String handle,
//     required String code, required otpType,
//   }) async {
//     final url = Uri.parse('$baseUrl/auth/verify_user');

//     try {
    
//       print("🔹 Sending request to: $url");
//       print("📩 Request Body: ${jsonEncode({"handle": handle, "code": code})}");

//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "handle": handle,
//           "code": code,
//         }),
//       );

//       print("📬 Response Code: ${response.statusCode}");
//       print("📜 Response Body: ${response.body}");

//       final responseData = jsonDecode(response.body);
//       final int statusCode = response.statusCode;

//       if (statusCode == 200 && responseData["type"] == "success") {
//         print("✅ User verification successful.");
//         return {
//           "success": true,
//           "message": responseData["message"] ?? "User verified successfully.",
//           "data": responseData["data"],
//           "showToast": responseData["showToast"] ?? false,
//         };
//       } else if (statusCode == 422) {
       
//         final errors = responseData["data"] ?? {};
//         if (errors.containsKey("handle")) {
//           print("❌ Error: Handle does not exist.");
//           return {
//             "success": false,
//             "message": "Handle does not exist.",
//             "errors": errors,
//           };
//         } else if (errors.containsKey("user_already_verified")) {
//           print("❌ Error: User already verified.");
//           return {
//             "success": false,
//             "message": "You have already verified your account before.",
//             "errors": errors,
//           };
//         }
//         print("⚠️ Validation error occurred.");
//         return {
//           "success": false,
//           "message": responseData["message"] ?? "Validation error.",
//           "errors": errors,
//         };
//       } else if (statusCode == 404) {
//         print("❌ Error: User not found.");
//         return {
//           "success": false,
//           "message": "User not found, please check your email.",
//         };
//       } else {
//         print("⚠️ Unknown error occurred.");
//         return {
//           "success": false,
//           "message": responseData["message"] ?? "Something went wrong.",
//         };
//       }
//     } catch (error) {
//       print("🚨 Request Error: $error");
//       return {
//         "success": false,
//         "message": "Failed to verify user: $error",
//       };
//     }
//   }
// }



