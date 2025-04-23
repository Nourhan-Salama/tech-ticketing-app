import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tech_app/screens/login.dart';
import 'package:tech_app/util/colors.dart';


class SplashScreen extends StatelessWidget {
  static const String routeName='/splash';
  @override
  Widget build(BuildContext context) {
  
    Timer(Duration(seconds: 5), () {
 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), 
      );
    });

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
          //letterSpacing: 1.5,
          shadows: [
            Shadow(
              blurRadius: 2.0,
             // color: ,
              offset: Offset(1.0, 1.0),)
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
          //letterSpacing: 0.5,
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
