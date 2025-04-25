import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool seen;
  final String body;
  final NotificationData data;
  final bool read;


  NotificationModel({
    required this.read,
    required this.id,
    required this.title,
    required this.createdAt,
    required this.seen,
    required this.body,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['id'] ?? '',
        title: json['title'] ?? 'No Title',
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
        seen: json['seen'] ?? false,
        body: json['body'] ?? '',
        data: NotificationData.fromJson(json['data'] ?? {}),
        read: json['read'] ?? false, 
      );
    } catch (e) {
      debugPrint('Error parsing NotificationModel: $e');
      rethrow;
    }
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class NotificationData {
  final String type;
  final int modelId;

  NotificationData({
    required this.type,
    required this.modelId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      type: json['type'] ?? 'unknown',
      modelId: json['model_id'] ?? 0,
    );
  }
}