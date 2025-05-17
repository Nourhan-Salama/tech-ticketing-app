import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/cubits/Conversations/conversation-cubit.dart';
import 'package:tech_app/models/ticket-details-model.dart';
import 'package:tech_app/models/ticket-model.dart';
import 'package:tech_app/util/colors.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketDetailsModel ticket;
  final TicketModel userTicket;

  const TicketDetailsScreen({
    Key? key,
    required this.userTicket,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('✅ Loaded Ticket Details:');
    print('Ticket ID: ${ticket.id}');
    print('Title: ${ticket.title}');
    print('User ID: ${userTicket.user.id}');
    print('User Name: ${ticket.userName}');
    print('Manager ID: ${userTicket.manager?.id}');
    print('Manager Name: ${ticket.managerName}');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final conversationsCubit = BlocProvider.of<ConversationsCubit>(context);

    Future<void> _handleChatWithManager() async {
      if (userTicket.manager == null) {
        print('❌ No manager assigned for ticket ID: ${ticket.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No manager assigned to this ticket')),
        );
        return;
      }

      print('📌 Ticket ID: ${ticket.id}');
      print('👤 Manager ID: ${userTicket.manager!.id}');
      print('🧑‍💼 Manager Name: ${ticket.managerName}');

      try {
        final conversation = await conversationsCubit.getOrCreateConversationWithUser(
          userTicket.manager!.id,
        );

        print('💬 Conversation ID with Manager: ${conversation?.id}');

        if (conversation?.id != null) {
          Navigator.pushNamed(
            context,
            '/chat-screen',
            arguments: {
              'conversationId': conversation!.id,
              'userId': userTicket.manager!.id,
              'userName': ticket.managerName ?? 'Manager',
              'ticketId': ticket.id,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start conversation with manager')),
          );
        }
      } catch (e) {
        print('❗ Error while starting chat with manager: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    Future<void> _handleChatWithUser() async {
      print('📌 Ticket ID: ${ticket.id}');
      print('👤 User ID: ${userTicket.user.id}');
      print('🙍‍♂️ User Name: ${ticket.userName}');
     

      try {
        final conversation = await conversationsCubit.getOrCreateConversationWithUser(
          userTicket.user.id,
        );

        print('💬 Conversation ID with User: ${conversation?.id}');

        if (conversation?.id != null) {
          Navigator.pushNamed(
            context,
            '/chat-screen',
            arguments: {
              'conversationId': conversation!.id,
              'userId': userTicket.user.id,
              'userName': ticket.userName,
              'ticketId': ticket.id,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start conversation with user')),
          );
        }
      } catch (e) {
        print('❗ Error while starting chat with user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(title: 'Ticket Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoColumn(screenHeight, true)),
                SizedBox(width: screenWidth * 0.05),
                Expanded(child: _buildInfoColumn(screenHeight, false)),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ticket.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            const Text(
              'Quick Chat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _handleChatWithManager,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Chat with Manager',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleChatWithUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Chat with User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(double screenHeight, bool leftSide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftSide) ...[
          _buildInfoItem('Ticket ID', '${ticket.id}'),
          SizedBox(height: screenHeight * 0.02),
          _buildStatusItem(ticket.statusText, ticket.statusColor),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('Service', ticket.serviceName),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('Manager', ticket.managerName ?? 'No Manager'),
        ] else ...[
          _buildInfoItem('Title', ticket.title),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('User', ticket.userName),
          SizedBox(height: screenHeight * 0.02),
          _buildInfoItem('Technician', ticket.technicianName ?? 'No Technician'),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

