import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:tech_app/Widgets/message-input.dart';
import 'package:tech_app/cubits/chat/chat_cubit.dart';
import 'package:tech_app/cubits/chat/chat_state.dart';
import 'package:tech_app/models/chat_message.dart';
import 'package:tech_app/services/message-service.dart';
import 'package:tech_app/services/pusher-service.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat-screen';
  final String conversationId;
  final String ticketId;
  final String userName;
  final int userId;
  final String? userAvatar;
  final int userType;
  final int receiverId; // Add this

  const ChatScreen({
    required this.userType,
    required this.conversationId,
    required this.ticketId,
    required this.userName,
    required this.userId,
    required this.receiverId, // Add this
    this.userAvatar,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late MessagesCubit _messagesCubit;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messagesCubit = MessagesCubit(
      messagesService: MessagesService(), 
      userType: widget.userType,
      currentUserId: widget.userId, // Add this
    );
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await PusherService.initPusher(userId: widget.userId.toString());
      await PusherService.subscribeToConversation(widget.conversationId);

      PusherService.setOnEventHandler((PusherEvent event) {
        if (event.eventName == 'new_message') {
          final messageData = json.decode(event.data);
          // Verify the message is for this conversation
          if (messageData['conversation_id'] == widget.conversationId) {
            final message = ChatMessage.fromJson(messageData);
            _messagesCubit.addNewMessage(message);
            _scrollToBottom();
          }
        }
      });

      await _messagesCubit.loadMessages(widget.conversationId);
      _scrollToBottom();
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    try {
      await _messagesCubit.sendMessage(
        conversationId: widget.conversationId,
        content: text,
        type: MessageType.text,
        ticketId: widget.ticketId,
        receiverId: widget.receiverId, // Add this
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    PusherService.unsubscribeFromConversation(widget.conversationId);
    _messagesCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _messagesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.userAvatar != null
                    ? NetworkImage(widget.userAvatar!)
                    : const AssetImage('assets/icons/avatar.png') as ImageProvider,
                radius: 16,
              ),
              const SizedBox(width: 12),
              Text(widget.userName),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Ticket #${widget.ticketId}',
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
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe = message.senderId == widget.userId;
                              final time = DateFormat('h:mm a').format(message.createdAt);

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blueAccent
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.content ?? '',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import 'package:tech_app/Widgets/message-input.dart';
// import 'package:tech_app/cubits/chat/chat_cubit.dart';
// import 'package:tech_app/cubits/chat/chat_state.dart';
// import 'package:tech_app/models/chat_message.dart';
// import 'package:tech_app/services/message-service.dart';
// import 'package:tech_app/services/pusher-service.dart';

// class ChatScreen extends StatefulWidget {
//   static const String routeName = '/chat-screen';
//   final String conversationId;
//   final String ticketId;
//   final String userName;
//   final int userId;
//   final String? userAvatar;
//   final int userType ;

//   const ChatScreen({
//     required this.userType,
//     required this.conversationId,
//     required this.ticketId,
//     required this.userName,
//     required this.userId,
//     this.userAvatar,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late MessagesCubit _messagesCubit;
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _messagesCubit = MessagesCubit(messagesService: MessagesService(),  userType: widget.userType, );
//     _initializeChat();
//   }

//   Future<void> _initializeChat() async {
//     try {
//       // Init and subscribe to correct conversation
//       await PusherService.initPusher(userId: widget.userId.toString());
//       await PusherService.subscribeToConversation(widget.conversationId);

//       // Listen only to this conversation's events
//       PusherService.setOnEventHandler((PusherEvent event) {
//         if (event.eventName == 'new_message') {
//           final message = ChatMessage.fromJson(json.decode(event.data));
//           _messagesCubit.addNewMessage(message);
//           _scrollToBottom();
//         }
//       });

//       // Load previous messages
//       await _messagesCubit.loadMessages(widget.conversationId);
//       _scrollToBottom();
//     } catch (e) {
//       print('Error initializing chat: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _sendMessage(String text) async {
//     try {
//       await _messagesCubit.sendMessage(
//         conversationId: widget.conversationId,
//         content: text,
//         type: MessageType.text,
//         ticketId: widget.ticketId,
//       );
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send message: ${e.toString()}')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     PusherService.unsubscribeFromConversation(widget.conversationId);
//     _messagesCubit.close();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _messagesCubit,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             children: [
//               CircleAvatar(
//                 backgroundImage: widget.userAvatar != null
//                     ? NetworkImage(widget.userAvatar!)
//                     : const AssetImage('assets/icons/avatar.png') as ImageProvider,
//                 radius: 16,
//               ),
//               const SizedBox(width: 12),
//               Text(widget.userName),
//             ],
//           ),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(24),
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 'Ticket #${widget.ticketId}',
//                 style: const TextStyle(fontSize: 12, color: Colors.white70),
//               ),
//             ),
//           ),
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Expanded(
//                     child: BlocBuilder<MessagesCubit, MessagesState>(
//                       builder: (context, state) {
//                         if (state is MessagesInitial || state is MessagesLoading) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (state is MessageError) {
//                           return Center(child: Text(state.message));
//                         } else if (state is MessagesLoaded) {
//                           return ListView.builder(
//                             controller: _scrollController,
//                             reverse: true,
//                             padding: const EdgeInsets.all(8),
//                             itemCount: state.messages.length,
//                             itemBuilder: (context, index) {
//                               final message = state.messages[index];
//                               final isMe = message.senderId == widget.userId;
//                               final time = DateFormat('h:mm a').format(message.createdAt);

//                               return Align(
//                                 alignment: isMe
//                                     ? Alignment.centerRight
//                                     : Alignment.centerLeft,
//                                 child: Container(
//                                   margin: const EdgeInsets.symmetric(vertical: 4),
//                                   padding: const EdgeInsets.all(12),
//                                   constraints: BoxConstraints(
//                                     maxWidth: MediaQuery.of(context).size.width * 0.75,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isMe
//                                         ? Colors.blueAccent
//                                         : Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: isMe
//                                         ? CrossAxisAlignment.end
//                                         : CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         message.content ?? '',
//                                         style: TextStyle(
//                                           color: isMe ? Colors.white : Colors.black,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         time,
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: isMe ? Colors.white70 : Colors.black54,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         }
//                         return const Center(child: Text('No messages yet'));
//                       },
//                     ),
//                   ),
//                   MessageInputField(
//                     onSend: _sendMessage,
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

