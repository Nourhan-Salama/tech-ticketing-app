
import 'package:flutter/material.dart';
import 'package:tech_app/Helper/app-bar.dart';

class Profile extends StatelessWidget {
 static const routName = '/profile';
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(
      title:'Profile'),
    );
  }
}