// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<ApiResponse> sendMessage(String conversationId, MessageData messageData) async {
//   final url = Uri.parse('https://graduation.arabic4u.org/api/conversations/$conversationId/messages');
  
//   final headers = {
//     'Content-Type': 'application/json',
//   };

//   final body = jsonEncode({
//     'data': messageData.toJson(),
//     'message': 'Resource Created Successfully',
//     'type': 'success',
//     'code': 201,
//     'showToast': true,
//   });

//   try {
//     final response = await http.post(url, headers: headers, body: body);

//     if (response.statusCode == 201) {
//       return ApiResponse.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to send message: ${response.statusCode}');
//     }
//   } catch (e) {
//     throw Exception('Error sending message: $e');
//   }
// }


