import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend URL
  final String _baseUrl = 'http://localhost:3000';

  // Send a message to the backend
  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/message'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['bot_response'] ?? 'No response';
    } else {
      throw Exception('Failed to send message');
    }
  }

  // Get all conversations
  Future<List<Map<String, String>>> getConversations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/conversations'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((conversation) {
        return {
          'id': conversation['_id']?.toString() ?? '', // Ensure _id is included
          'user_message':
              conversation['user_message']?.toString() ?? 'No message',
          'bot_response':
              conversation['bot_response']?.toString() ?? 'No response',
          'timestamp': conversation['timestamp']?.toString() ?? 'No timestamp',
        };
      }).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  // Delete a conversation by ID
  Future<void> deleteConversation(String conversationId) async {
    final url = Uri.parse('$_baseUrl/conversations/$conversationId');

    try {
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete conversation');
      }
    } catch (error) {
      print('Error deleting conversation: $error');
      throw error;
    }
  }
}
