// import 'package:flutter/material.dart';
// import 'package:tech_app/models/ticket-model.dart';

// class RecentTickets extends StatelessWidget {
//   final List<TicketModel> tickets;
  
//   const RecentTickets({super.key, required this.tickets});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Recent Tickets',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...tickets.take(4).map((ticket) => Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 ticket.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(ticket.status).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   _getStatusText(ticket.status),
//                   style: TextStyle(
//                     color: _getStatusColor(ticket.status),
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )).toList(),
//         if (tickets.length > 4) TextButton(
//           onPressed: () {
//             // Navigate to full tickets list
//           },
//           child: const Text('View All'),
//         ),
//       ],
//     );
//   }

//   String _getStatusText(int status) {
//     switch (status) {
//       case 0: return 'Pending';
//       case 1: return 'In Progress';
//       case 2: return 'Completed';
//       case 3: return 'Closed';
//       default: return 'Unknown';
//     }
//   }

//   Color _getStatusColor(int status) {
//     switch (status) {
//       case 0: return Colors.grey;
//       case 1: return Colors.blue;
//       case 2: return Colors.green;
//       case 3: return Colors.red;
//       default: return Colors.grey;
//     }
//   }
// }