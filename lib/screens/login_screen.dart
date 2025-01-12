import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import the custom colors file

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  // Function to handle login
  Future<void> _login() async {
    try {
      // Authenticate user with email and password
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // Navigate to the dashboard on successful login
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        throw 'Login failed. Please check your credentials.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightCream, // Soft background color
      body: Center(
        child: Container(
          width: 400, // Fixed width for better web compatibility
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo or Placeholder
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    CustomColors.sunsetOrange, // Electric blue background
                child: Icon(Icons.lock, size: 40, color: Colors.black),
              ),
              SizedBox(height: 20),
              // Login Heading
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Neon pink text
                ),
              ),
              SizedBox(height: 20),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Colors.black), // Pastel purple for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email,
                      color: CustomColors.sunsetOrange), // Electric blue icon
                ),
              ),
              SizedBox(height: 15),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Colors.black), // Pastel purple for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock,
                      color: CustomColors.sunsetOrange), // Electric blue icon
                ),
              ),
              SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor:
                      CustomColors.sunsetOrange, // Sunset orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Signup Redirect
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(
                    color: Colors.black, // Neon pink text for the link
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
