import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For image handling
import 'package:supabase_flutter/supabase_flutter.dart';
// Import the custom colors file

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Uint8List? imageBytes; // To store the selected image bytes
  String profileImageStatus = ''; // Status message for profile image

  final supabase = Supabase.instance.client;

  // Function to pick an image
  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedImage != null) {
      imageBytes = await pickedImage.readAsBytes();
      setState(() {
        profileImageStatus = 'Profile Image Updated!';
      });
    } else {
      setState(() {
        profileImageStatus = 'No Image Selected';
      });
    }
  }

  // Function to handle user sign-up
  Future<void> _signup() async {
    try {
      // Sign up user with email and password
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = response.user?.id;

      if (userId != null) {
        // Upload profile image if selected
        String? imageUrl;
        if (imageBytes != null) {
          final filePath = 'profile_images/$userId';
          await supabase.storage
              .from(
                  'profiles') // Ensure the 'profiles' bucket exists in Supabase
              .uploadBinary(filePath, imageBytes!);
          imageUrl = supabase.storage.from('profiles').getPublicUrl(filePath);
        }

        // Save user details to the database
        await supabase.from('users').insert({
          'id': userId,
          'image_url': imageUrl,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        // Navigate to the dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        throw 'Sign-up failed. Please try again.';
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
              // Profile Image Picker
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      CustomColors.sunsetOrange, // Electric blue background
                  backgroundImage:
                      imageBytes != null ? MemoryImage(imageBytes!) : null,
                  child: imageBytes == null
                      ? Icon(Icons.camera_alt,
                          size: 40, color: Colors.black) // Neon Pink icon
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text(
                profileImageStatus,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black, // Neon pink status
                ),
              ),
              SizedBox(height: 20),
              // Full Name Input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle:
                      TextStyle(color: Colors.black), // Pastel purple label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person,
                      color: CustomColors.sunsetOrange), // Electric Blue icon
                ),
              ),
              SizedBox(height: 15),
              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Colors.black), // Pastel purple label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email,
                      color: CustomColors.sunsetOrange), // Electric Blue icon
                ),
              ),
              SizedBox(height: 15),
              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Colors.black), // Pastel purple label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock,
                      color: CustomColors.sunsetOrange), // Electric Blue icon
                ),
              ),
              SizedBox(height: 20),
              // Sign Up Button
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor:
                      CustomColors.sunsetOrange, // Sunset orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Sign Up'),
              ),
              SizedBox(height: 15),
              // Login Redirect
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text(
                  'Already have an account? Log in',
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
