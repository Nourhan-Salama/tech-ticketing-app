// chat_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:tech_app/Widgets/message-input.dart';
import 'package:tech_app/cubits/chat/chat_cubit.dart';
import 'package:tech_app/cubits/chat/chat_state.dart';
import 'package:tech_app/models/chat_message.dart';
import 'package:tech_app/services/message-service.dart';
import 'package:tech_app/services/pusher-service.dart';


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
  late MessagesCubit _messagesCubit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messagesCubit = MessagesCubit(messagesService: MessagesService());
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (widget.conversationId != null) {
      // Initialize Pusher
      await PusherService.initPusher(userId: widget.userId.toString());
      await PusherService.subscribeToConversation(widget.conversationId!);
      
      PusherService.onEvent = (PusherEvent event) {
        if (event.eventName == 'new_message') {
          final messageData = json.decode(event.data);
          final message = ChatMessage.fromJson(messageData);
          _messagesCubit.emit(MessagesLoaded([
            message,
            ...(_messagesCubit.state as MessagesLoaded).messages,
          ]));
        }
      };

      // Load existing messages
      await _messagesCubit.loadMessages(widget.conversationId!);
    }
    setState(() => _isLoading = false);
  }

  void _sendMessage(String text) {
    if (widget.conversationId == null) return;
    
    _messagesCubit.sendMessage(
      conversationId: widget.conversationId!,
      content: text,
      type: MessageType.text,
      ticketId: widget.ticketId,
    );
  }

  @override
  void dispose() {
    if (widget.conversationId != null) {
      PusherService.unsubscribeFromConversation(widget.conversationId!);
    }
    _messagesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _messagesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.userName),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Ticket ID: ${widget.ticketId} | Conversation ID: ${widget.conversationId ?? "Not created"}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: BlocBuilder<MessagesCubit, MessagesState>(
                      builder: (context, state) {
                        if (state is MessagesInitial || state is MessagesLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is MessageError) {
                          return Center(child: Text(state.message));
                        } else if (state is MessagesLoaded) {
                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe = message.senderId == widget.userId;
                              
                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blueAccent
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    message.content ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text('No messages yet'));
                      },
                    ),
                  ),
                  MessageInputField(
                    onSend: _sendMessage,
                  ),
                ],
              ),
      ),
    );
  }
}


