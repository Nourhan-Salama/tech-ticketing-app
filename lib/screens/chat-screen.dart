// chat_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:tech_app/Widgets/message-input.dart';
import 'package:uuid/uuid.dart';
import 'package:tech_app/services/conversations-service.dart';
import 'package:tech_app/services/pusher-service.dart';
import 'package:tech_app/models/conversation-model.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String ticketId;
  final String userName;
  final int userId;

  const ChatScreen({
    this.conversationId,
    required this.ticketId,
    required this.userName,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  late ConversationsService _conversationsService;
  Conversation? _conversation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _conversationsService = ConversationsService();
    _initializeConversation();
  }

  Future<void> _initializeConversation() async {
    try {
      if (widget.conversationId == null) {
        // Create new conversation if one doesn't exist
        _conversation = await _conversationsService.createConversationWithUser(widget.userId);
      } else {
        // Get existing conversation
        _conversation = await _conversationsService.getConversationWithUser(widget.userId);
      }

      if (_conversation != null) {
        // Initialize Pusher for this conversation
        await PusherService.initPusher(userId: _conversation!.otherUser?.id.toString() ?? '0');
        await PusherService.subscribeToConversation(_conversation!.id);
        
        // Set up Pusher event listener
        PusherService.onEvent = (PusherEvent event) {
          if (event.eventName == 'new_message') {
            // Handle new message
            final messageData = json.decode(event.data);
            _handleIncomingMessage(messageData);
          }
        };
      }
    } catch (e) {
      print('Error initializing conversation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> messageData) {
    // Process incoming message and add to _messages
    setState(() {
      _messages.insert(0, {
        'id': messageData['id'],
        'text': messageData['content'],
        'isImage': false,
        'isMe': false,
        'time': DateTime.parse(messageData['created_at']),
      });
    });
  }

  void _sendMessage(String text) async {
    if (_conversation == null) return;

    final message = {
      'id': const Uuid().v4(),
      'text': text,
      'isImage': false,
      'isMe': true,
      'time': DateTime.now(),
    };
    
    setState(() => _messages.insert(0, message));
    
    // Here you would typically send the message to your API
    // await _conversationsService.sendMessage(
    //   conversationId: _conversation!.id,
    //   content: text,
    //   type: 0, // text message
    // );
  }

  @override
  void dispose() {
    if (_conversation != null) {
      PusherService.unsubscribeFromConversation(_conversation!.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Ticket ID: ${widget.ticketId} | Conversation ID: ${_conversation?.id ?? "Not created"}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] ?? false;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: msg['isImage']
                              ? Image.file(msg['file'])
                              : Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          MessageInputField(
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}


