import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_app/services/pusher-service.dart';
import 'screens/ticketing-app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(); 

  // Check if user is already logged in
  final secureStorage = const FlutterSecureStorage();
  final loggedUserId = await secureStorage.read(key: 'user_id');
  
  if (loggedUserId != null) {
    try {
      await PusherService.initPusher(userId: loggedUserId);
    } catch (e) {
      print('Pusher initialization failed: $e');
    }
  }
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  try {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'test_key', value: 'test_value');
    await storage.read(key: 'test_key');
    await storage.delete(key: 'test_key');
    print('✅ Secure storage test successful');
  } catch (e) {
    print('❌ Secure storage failed: $e');
  }

  runApp(TicketingApp(sharedPreferences: preferences));
}

