// screens/chat-screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Widgets/message-input.dart';
import 'package:tech_app/cubits/get-chat-cubit.dart';
import 'package:tech_app/services/pusher-service.dart';


class ChatScreen extends StatefulWidget {
  final String conversationId;
  final int ticketId;
  final String userName;

  const ChatScreen({
    required this.conversationId,
    required this.ticketId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    print('Initializing ChatScreen for conversation ${widget.conversationId}');
   // _initializePusher();
    _loadMessages();
  }

  // Future<void> _initializePusher() async {
  //   print('Initializing Pusher for ChatScreen...');
  //   try {
  //     final userId = await PusherService.getUserId();
  //     if (userId != null) {
  //       await PusherService.subscribeToConversation(widget.conversationId);
  //       print('Subscribed to conversation ${widget.conversationId}');
  //     } else {
  //       print('Failed to subscribe to conversation: User ID not found');
  //     }
  //   } catch (e) {
  //     print('Error initializing Pusher in ChatScreen: $e');
  //   }
  // }

  void _loadMessages() {
    print('Loading messages for conversation ${widget.conversationId}');
    final chatCubit = context.read<ChatCubit>();
   // chatCubit.loadMessages(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    print('Building ChatScreen...');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.error != null) {
            print('Error in ChatScreen: ${state.error}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          print('Current state in ChatScreen: ${state.runtimeType}');
          
          if (state is ChatInitial || state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentState = state as ChatLoaded;
          print('Displaying ${currentState.messages.length} messages');

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: currentState.messages.length,
                  itemBuilder: (context, index) {
                    final message = currentState.messages[index];
                    print('Building message: ${message.id}');
                    
                    return Align(
                      alignment: message.isMe 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4, 
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isMe 
                              ? Colors.blue[100] 
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                ),
              ),
              MessageInputField(
                onSend: (text) {
                  print('Sending message: $text');
                 // context.read<ChatCubit>().sendMessage(text);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing ChatScreen...');
    PusherService.unsubscribeFromConversation(widget.conversationId);
    super.dispose();
  }
}
