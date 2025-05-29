import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

import 'package:tech_app/screens/login.dart';
import 'package:tech_app/services/notifications-services.dart';
import 'package:tech_app/util/colors.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🚀 initState called in SplashScreen');
    requestNotificationPermission();

    // Navigate to LoginScreen after 5 seconds
    Timer(Duration(seconds: 5), () {
      print('⏳ 5 seconds passed, navigating to LoginScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  void requestNotificationPermission() async {
    print('🔔 Requesting notification permission...');
    if (Platform.isAndroid) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📋 Authorization status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notifications authorized');
        await getFcmTokenAndSend();
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Notifications permission denied');
      } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        print('⚠️ Notifications permission not determined');
      } else {
        print('🔔 Other authorization status: ${settings.authorizationStatus}');
      }
    } else {
      print('⚠️ Notification permissions not requested: Not Android platform');
    }
  }

  Future<void> getFcmTokenAndSend() async {
    print('🔄 Starting to get FCM Token...');
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('✅ FCM Token received: $fcmToken');
        await NotificationService().updateFcmToken(fcmToken);
        print('✔️ FCM Token sent to backend successfully.');
      } else {
        print('⚠️ FCM Token is null or empty.');
      }
    } catch (e) {
      print('⚠️ Error when getting or sending FCM Token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsHelper.darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/Group.png',
              height: 100,
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'TICKETING',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0031DE),
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          offset: Offset(1.0, 1.0),
                        )
                      ],
                    ),
                  ),
                  TextSpan(
                    text: 'App',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

