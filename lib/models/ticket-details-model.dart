import 'package:flutter/material.dart';

class TicketDetailsModel {
  final int id;
  final String title;
  final String description;
  final int status;
  final String serviceName;
  final String userName;
  final String? managerName;
  final String? technicianName;

  TicketDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.serviceName,
    required this.userName,
    this.managerName,
    this.technicianName,
  });

  factory TicketDetailsModel.fromJson(Map<String, dynamic> json) {
    return TicketDetailsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0, // Default to PENDING (0)
      serviceName: json['service']?['name'] ?? 'No Service',
      userName: json['user']?['name'] ?? 'Unknown',
      managerName: json['manager']?['user']?['name'],
      technicianName: json['technician']?['user']?['name'],
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Resolved';
      case 3:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0: // Pending
        return Colors.grey;
      case 1: // In Progress
        return Colors.orange;
      case 2: // Resolved
        return Colors.green;
      case 3: // Closed
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
