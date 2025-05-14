import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/Widgets/search-chat.dart';
import 'package:tech_app/cubits/Conversations/conversatins-state.dart';
import 'package:tech_app/cubits/Conversations/conversation-cubit.dart';

import 'package:tech_app/models/conversation-model.dart';
import 'package:tech_app/screens/chat-screen.dart';

class ConversationsScreen extends StatefulWidget {
  static const String routeName = '/conversations';
  final int? ticketId;
  final String? userName;
  final int? userId;
  //final Conversation? conversation;

  const ConversationsScreen({Key? key, this.ticketId,this.userId,this.userName}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String? _selectedConversationId;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cubit = context.read<ConversationsCubit>();
    await cubit.loadConversations();
    
    // If a ticketId was provided, try to find its conversation
    if (widget.ticketId != null) {
      final state = cubit.state;
      if (state is ConversationsLoaded) {
        final conversation = state.allConversations.firstWhere(
          (conv) => conv.ticketId == widget.ticketId,
          orElse: () => Conversation(
            id: '',
            type: 0,
            pinned: false,
            ticketId: widget.ticketId,
          ),
        );
        
        if (conversation.id.isNotEmpty) {
          _openChat(context, conversation);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Chats'),
      body: BlocConsumer<ConversationsCubit, ConversationsState>(
        listener: (context, state) {
          if (state is ConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ConversationsInitial || state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentState = state as ConversationsLoaded;
          final conversations = currentState.filteredConversations;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchChat(),
              ),
              Expanded(
                child: conversations.isEmpty
                    ? const Center(child: Text('No conversations found'))
                    : ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(conversation.avatarUrl),
                            ),
                            title: Text(conversation.title),
                            subtitle: Text(conversation.lastMessage),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_formatTime(conversation.lastMessageTime)),
                                if (conversation.unread)
                                  const Icon(Icons.brightness_1, size: 12, color: Colors.blue),
                              ],
                            ),
                            onTap: () => _openChat(context, conversation),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _openChat(BuildContext context, Conversation conversation) {
    _selectedConversationId = conversation.id;
  
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          ticketId: conversation.ticketId!.toString(),

          userName: conversation.title,  userId: conversation.otherUser?.id ?? widget.userId ?? 0, 
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
