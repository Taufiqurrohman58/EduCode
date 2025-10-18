import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', 
              height: 60,
            ),
            const Text(
              'EDUCODE',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "arimo",
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
