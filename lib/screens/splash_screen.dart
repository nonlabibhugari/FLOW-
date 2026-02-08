import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 25),
            Text(
              "مرحباً بك في Flow",
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}