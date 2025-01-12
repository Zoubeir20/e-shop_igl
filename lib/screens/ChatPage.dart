import 'package:flutter/material.dart';

class Chatpage extends StatelessWidget {
  const Chatpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Chat Page'),
      ),
    );
  }
}
