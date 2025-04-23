
import 'package:flutter/material.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/Widgets/search-chat.dart';
import 'package:tech_app/screens/chat-screen.dart';


class ChatsPage extends StatefulWidget {
  static const routeName = '/chat';
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {

  final List<Map<String, String>> chatList = []; 

   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     // key: _scaffoldKey,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Chats'),
      body: ListView(
        children: [
          SizedBox(height: 10,),
          SearchChat(),

         
          Expanded(
            child: chatList.isEmpty
                ? _buildNoChatsUI() 
                : _buildChatList(),  
          ),
        ],
      ),
    );
  }

  Widget _buildNoChatsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "There are no chats yet!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Start by creating a new ticket.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  
  Widget _buildChatList() {
    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        var chat = chatList[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(chat["avatar"]!),
          ),
          title: Text(chat["name"]!),
          subtitle: Text(chat["message"]!),
          trailing: Text(chat["time"]!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(userName: chat["name"]!),
              ),
            );
          },
        );
      },
    );
  }
}


