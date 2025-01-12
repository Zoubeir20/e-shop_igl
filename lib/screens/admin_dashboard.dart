import 'package:e_shop_igl/screens/HomePage.dart';
import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:e_shop_igl/ui/sidebar.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; // For authentication
// Import custom colors

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _currentContent = Homepage();

  // Function to update the current content area
  void _updateContent(Widget newContent) {
    setState(() {
      _currentContent = newContent;
    });
  }

  // Function to show the confirmation dialog
  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without logging out
              },
            ),
            TextButton(
              child: Text('Log out'),
              onPressed: () async {
                // Log out logic here
                await Supabase.instance.client.auth.signOut();
                print("Logout succeeded");
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CustomColors.lightCream, // Cream background similar to login
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor:
            CustomColors.sunsetOrange, // Electric blue AppBar for consistency
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog, // Show the logout confirmation dialog
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar with dynamic menu item callbacks
          Sidebar(onMenuItemSelected: _updateContent),

          // Content Area with rounded corners and soft shadow
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_currentContent),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white, // White content area
                  borderRadius: BorderRadius.circular(16), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.lightCream.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _currentContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
