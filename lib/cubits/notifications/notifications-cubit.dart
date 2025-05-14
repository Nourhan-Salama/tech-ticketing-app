import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/notifications/notifications-stae.dart';
import 'package:tech_app/services/notifications-services.dart';


class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationService _service;

  NotificationsCubit(this._service) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final notifications = await _service.getAllNotifications();
      final unreadCount = await _service.getUnreadCount();
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

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
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