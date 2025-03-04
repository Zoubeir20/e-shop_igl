//import 'package:e_shop_igl/screens/admin_dashboard.dart';
import 'package:e_shop_igl/screens/admin_dashboard.dart';
import 'package:e_shop_igl/screens/login_screen.dart';
import 'package:e_shop_igl/screens/signup_screen.dart';
import 'package:e_shop_igl/screens/splashscreen.dart';
import 'package:e_shop_igl/screens/FavPage.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://aioymmysesdbgwvblead.supabase.co', // Replace with your Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpb3ltbXlzZXNkYmd3dmJsZWFkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU5MjYzMjcsImV4cCI6MjA1MTUwMjMyN30.PxV9zVcrZlOGRaFRVwc0ogZTDEDgVh3CrCWwiMioMV8', // Replace with your Supabase anon key
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Dashboard',
      home: SplashScreen(), // Default route
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/dashboard': (context) => AdminDashboard(),
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}
