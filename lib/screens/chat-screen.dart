import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tech_app/Widgets/message-input.dart';
import 'package:uuid/uuid.dart';


class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String ticketId;
  final String userName;

  const ChatScreen({
    this.conversationId,
    required this.ticketId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage(String text) {
    final message = {
      'id': const Uuid().v4(),
      'text': text,
      'isImage': false,
      'isMe': true,
      'time': DateTime.now(),
    };
    setState(() => _messages.insert(0, message));
  }

  // مثال توضيحي لو عايزة تدعمي الصور لاحقًا:
  void _sendImage(File imageFile) {
    final message = {
      'id': const Uuid().v4(),
      'file': imageFile,
      'isImage': true,
      'isMe': true,
      'time': DateTime.now(),
    };
    setState(() => _messages.insert(0, message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Ticket ID: ${widget.ticketId} | Conversation ID: ${widget.conversationId ?? "Not yet"}',
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


