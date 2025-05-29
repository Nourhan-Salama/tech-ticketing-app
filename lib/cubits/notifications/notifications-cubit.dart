import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/notifications/notifications-stae.dart';

import 'package:tech_app/models/notifications-model.dart';
import 'package:tech_app/services/notifications-services.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationService _service;
   
  NotificationsCubit(this._service) : super(NotificationsInitial());

  List<NotificationModel> _technicianNotifications = [];

  Future<void> loadNotifications() async {
    if (state is NotificationsLoaded) return;
    emit(NotificationsLoading());
    try {
      final notifications = await _service.getAllNotifications();
      final unreadCount = await _service.getUnreadCount();

      _technicianNotifications = notifications.where((n) =>
        n.data.type == NotificationType.ticketAssigned || 
        n.data.type == NotificationType.chat
      ).toList();

      if (unreadCount > 0) {
        await _service.playNotificationSound();
      }

      emit(NotificationsLoaded(notifications, unreadCount));
    } catch (e) {
      if (e.toString().contains('401')) {
        try {
          await _service.handleTokenRefresh();
          await loadNotifications();
        } catch (refreshError) {
          emit(NotificationsError('Session expired. Please login again.'));
        }
      } else {
        emit(NotificationsError('Failed to load notifications: ${e.toString()}'));
      }
    }
  }

  List<NotificationModel> get technicianNotifications => _technicianNotifications;

   Future<void> markAsRead(String notificationId) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;

      final notificationIndex = currentState.notifications.indexWhere(
        (n) => n.id == notificationId,
      );

      if (notificationIndex == -1) return;

      final notification = currentState.notifications[notificationIndex];
      if (notification.seen) return;  // Check seen instead of read

      try {
        await _service.markAsRead(notificationId);

        final updatedNotification = notification.copyWith(
          read: true,
          seen: true,  // Also update seen
        );
        final updatedNotifications = [...currentState.notifications];
        updatedNotifications[notificationIndex] = updatedNotification;

        final updatedUnreadCount = currentState.unreadCount - 1;

        emit(NotificationsLoaded(updatedNotifications, updatedUnreadCount));
      } catch (e) {
        emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read: ${e.toString()}'));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to delete notification: ${e.toString()}'));
    }
  }

  Future<void> deleteAll() async {
    try {
      await _service.deleteAllNotifications();
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to delete all notifications: ${e.toString()}'));
    }
  }
}


