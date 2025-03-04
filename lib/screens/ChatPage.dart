import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:e_shop_igl/services/api_service.dart';

class ApiService {
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

  Future<List<Map<String, String>>> getConversations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/conversations'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((conversation) {
        return {
          'id':
              conversation['_id']?.toString() ?? '', // Ensure 'id' is included
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

  Future<void> deleteConversation(String conversationId) async {
    final url = Uri.parse('$_baseUrl/conversations/$conversationId');

    try {
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete conversation');
      }
    } catch (error) {
      throw error;
    }
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  List<String> _messages = [];
  List<Map<String, String>> _conversations = [];
  bool _isNewConversation = false;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  void _fetchConversations() async {
    try {
      final conversations = await _apiService.getConversations();
      setState(() {
        _conversations = conversations;
      });
    } catch (error) {
      print('Error fetching conversations: $error');
    }
  }

  void _deleteConversation(int index) async {
    try {
      final conversationId = _conversations[index]['id'];
      if (conversationId != null) {
        await _apiService.deleteConversation(conversationId);
        setState(() {
          _conversations.removeAt(index);
        });
      }
    } catch (error) {
      print('Error deleting conversation: $error');
    }
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
    });

    try {
      final botResponse = await _apiService.sendMessage(message);
      setState(() {
        _messages.add('Bot: $botResponse');
        if (_isNewConversation) {
          _conversations.add({
            'user_message': message,
            'bot_response': botResponse,
          });
          _isNewConversation = false;
        }
      });
    } catch (error) {
      setState(() {
        _messages.add('Bot: Sorry, something went wrong.');
      });
    }
  }

  void _continueConversation(Map<String, String> conversation) {
    setState(() {
      _messages.clear();
      _messages.add('You: ${conversation['user_message']}');
      _messages.add('Bot: ${conversation['bot_response']}');
      _isNewConversation = false;
    });
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
      _isNewConversation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Bot'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Previous Conversations',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (ctx, index) {
                        final conversation = _conversations[index];
                        return ListTile(
                          title: Text(
                              conversation['user_message'] ?? 'No message'),
                          subtitle: Text(conversation['bot_response'] ??
                              'No bot response'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteConversation(index);
                            },
                          ),
                          onTap: () {
                            _continueConversation(conversation);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _startNewConversation,
                      child: Text('Start New Conversation'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(_messages[index]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            _sendMessage(_controller.text);
                            _controller.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
