import 'dart:ui_web';

import 'package:clica/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 200 ,
              child: Lottie.asset(AssetsManager.chatBubble),
            )
          ],
        ),
      ),
    );
  }
}