import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:tech_app/models/chat_message.dart' as chat;
import 'package:tech_app/cubits/chat/chat_cubit.dart';
import 'package:tech_app/cubits/chat/chat_state.dart' as chat_state;
import 'package:uuid/uuid.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String ticketId;
  final String userName;

  const ChatScreen({
    Key? key,
    required this.ticketId,
    required this.userName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _user = const types.User(
    id: 'technician',
    firstName: 'Technician',
  );

  void _handleSendPressed(types.PartialText message) {
    final textMessage = chat.ChatMessage(
      id: const Uuid().v4(),
      text: message.text,
      senderId: _user.id,
      senderName: _user.firstName ?? 'Technician',
      timestamp: DateTime.now(),
      ticketId: widget.ticketId,
      status: chat.MessageStatus.sending,
    );

    context.read<ChatCubit>().sendMessage(widget.ticketId, textMessage);
  }

  List<types.Message> _convertMessages(List<chat.ChatMessage> messages) {
    return messages.map((msg) => msg.toChatUIMessage()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatCubit, chat_state.ChatState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName),
                if (state is chat_state.ChatLoaded && state.isTyping)
                  const Text(
                    'typing...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<ChatCubit, chat_state.ChatState>(
        builder: (context, state) {
          if (state is chat_state.ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is chat_state.ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is chat_state.ChatLoaded) {
            return Chat(
              messages: _convertMessages(state.messages),
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: DefaultChatTheme(
                primaryColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            );
          }

          return const Center(child: Text('Start a conversation'));
        },
      ),
    );
  }

  @override
  void dispose() {
    context.read<ChatCubit>().dispose(widget.ticketId);
    super.dispose();
  }
} 