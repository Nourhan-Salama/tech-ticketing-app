import 'package:flutter/material.dart';

import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/models/ticket-details-model.dart';
import 'package:tech_app/util/colors.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketDetailsModel ticket;

  const TicketDetailsScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'Ticket Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar & Name Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.12, 
                    backgroundColor: ColorsHelper.darkBlue,
                    child: Text(
                      getInitials(ticket.userName),
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Section
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  backgroundColor: ticket.statusColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    
                    side: BorderSide.none,
                  ),
                  label: Text(
                    ticket.statusText,
                    style: TextStyle(
                      color: ticket.statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ticket Title (aligned with the rest)
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),

            // Description Section
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ticket.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Service Section
            _buildDetailRow('Service:', ticket.serviceName),
              // Manager Section (if exists)
            if (ticket.managerName != null)
              _buildDetailRow('Manager:', ticket.managerName!),

        
          ],
        ),
      ),
    );
  }

  /// Helper widget for label + value row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Return initials from name
  String getInitials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "";
  }
}
