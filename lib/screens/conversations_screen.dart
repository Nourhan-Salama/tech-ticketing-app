import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/screens/chat_screen.dart';
import 'package:tech_app/cubits/chat/chat_cubit.dart';

class ConversationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;

  const ConversationsScreen({
    Key? key,
    required this.tickets,
  }) : super(key: key);

  void _navigateToChatScreen(BuildContext context, String ticketId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatCubit()..initializeChat(ticketId),
          child: ChatScreen(
            ticketId: ticketId,
            userName: userName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(ticket['userName'] ?? 'Unknown User'),
            subtitle: Text('Ticket #${ticket['ticketId']}'),
            trailing: const Icon(Icons.chat_bubble_outline),
            onTap: () => _navigateToChatScreen(
              context,
              ticket['ticketId'],
              ticket['userName'] ?? 'Unknown User',
            ),
          );
        },
      ),
    );
  }
} 