// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AuthService {
//   static const String _baseUrl = "https://graduation.arabic4u.org/auth/register/user";

//   Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password, String confirmPassword) async {
//   final url = Uri.parse(_baseUrl);

//   try {
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "name": "$firstName $lastName",  
//         "email": email,
//         "password": password,
//         "password_confirmation": confirmPassword 
//       }),
//     );

//     final Map<String, dynamic> responseData = jsonDecode(response.body);

//     print("✅ API Full Response: $responseData"); 

//     if (response.statusCode == 201 && responseData["type"] == "success") {
//       return {"success": true, "message": responseData["message"]};
//     } else {
//       String errorMessage = responseData["message"] ?? "Registration failed";
//       if (responseData.containsKey("errors")) {
//         errorMessage = responseData["errors"].entries.map((e) => "${e.key}: ${e.value}").join("\n");
//       }

//       return {"success": false, "message": errorMessage};
//     }
//   } catch (e) {
//     return {"success": false, "message": "Error: $e"};
//   }
// }
// }