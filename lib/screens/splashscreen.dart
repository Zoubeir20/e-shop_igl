import 'package:e_shop_igl/screens/login_screen.dart';
import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Navigate to the next screen after 3 seconds
  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CustomColors.lightCream, // You can change the background color
      body: Center(
        child: Image.asset('assets/logo.png'), // Your logo image
      ),
    );
  }
}
