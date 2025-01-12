import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchUserProfile() async {
    // Get the current authenticated user's ID
    final userId = supabase.auth.currentUser?.id;

    if (userId != null) {
      // Fetch user data from the 'users' table
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      if (response != null) {
        return response;
      }
    }

    throw 'Unable to fetch user profile.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: CustomColors.lightCream,
      ),
      body: Center(
        child: Container(
          width: 500, // Set a fixed width for web compatibility
          padding: const EdgeInsets.all(16.0),
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
          child: FutureBuilder<Map<String, dynamic>>(
            future: fetchUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    'No profile data found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              final user = snapshot.data!;
              final profileImage = user['image_url'];
              final name = user['name'];
              final email = user['email'];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(height: 20),
                  // User's Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.sunsetOrange,
                    ),
                  ),
                  SizedBox(height: 10),
                  // User's Email
                  Text(
                    email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 30),
                  // Login Time
                  Text(
                    'Last Login: ${DateTime.now().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Edit Profile Logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit Profile coming soon!')),
                      );
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.lightCream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
