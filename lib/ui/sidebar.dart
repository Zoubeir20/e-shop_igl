import 'package:e_shop_igl/screens/ChatPage.dart';
import 'package:e_shop_igl/screens/FavPage.dart';
import 'package:e_shop_igl/screens/HomePage.dart';
import 'package:e_shop_igl/screens/PayScreen.dart';
import 'package:e_shop_igl/screens/profile_page.dart';
import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(Widget) onMenuItemSelected;

  Sidebar({required this.onMenuItemSelected});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0; // Track the selected index in sidebar

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: CustomColors.lightCream, // Set sidebar background to cream
        borderRadius: BorderRadius.horizontal(
            right: Radius.circular(16)), // Rounded right corner
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Dashboard Menu Item
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.black), // Black Icon
            title: Text('Dashboard',
                style: TextStyle(color: Colors.black)), // Black Text
            tileColor: _selectedIndex == 0
                ? CustomColors.electricBlue.withOpacity(
                    0.2) // Highlight active item with a softer background
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTap: () {
              widget.onMenuItemSelected(Homepage());
              setState(() {
                _selectedIndex = 1; // Update selected index
              });
            },
          ),
          // Settings Menu Item
          ListTile(
            leading: Icon(Icons.bus_alert, color: Colors.black), // Black Icon
            title: Text('Favorites',
                style: TextStyle(color: Colors.black)), // Black Text
            tileColor: _selectedIndex == 1
                ? CustomColors.electricBlue
                    .withOpacity(0.2) // Highlight active item
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTap: () {
              widget.onMenuItemSelected(Favpage());
              setState(() {
                _selectedIndex = 2; // Update selected index
              });
            },
          ),
          // Analytics Menu Item
          ListTile(
            leading: Icon(Icons.analytics, color: Colors.black), // Black Icon
            title: Text('Payment',
                style: TextStyle(color: Colors.black)), // Black Text
            tileColor: _selectedIndex == 2
                ? CustomColors.electricBlue
                    .withOpacity(0.2) // Highlight active item
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTap: () {
              widget.onMenuItemSelected(PayScreen());
              setState(() {
                _selectedIndex = 3; // Update selected index
              });
            },
          ),
          // Profile Menu Item
          ListTile(
            leading: Icon(Icons.person, color: Colors.black), // Black Icon
            title: Text('Chat',
                style: TextStyle(color: Colors.black)), // Black Text
            tileColor: _selectedIndex == 3
                ? CustomColors.electricBlue
                    .withOpacity(0.2) // Highlight active item
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTap: () {
              widget.onMenuItemSelected(Chatpage());
              setState(() {
                _selectedIndex = 4; // Update selected index
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.black), // Black Icon
            title: Text('Profile',
                style: TextStyle(color: Colors.black)), // Black Text
            tileColor: _selectedIndex == 3
                ? CustomColors.electricBlue
                    .withOpacity(0.2) // Highlight active item
                : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            onTap: () {
              widget.onMenuItemSelected(ProfilePage());
              setState(() {
                _selectedIndex = 5; // Update selected index
              });
            },
          ),
        ],
      ),
    );
  }
}
