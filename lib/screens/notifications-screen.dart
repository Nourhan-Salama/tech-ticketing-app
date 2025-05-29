import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tech_app/cubits/notifications/notifications-cubit.dart';
import 'package:tech_app/cubits/notifications/notifications-stae.dart';
import 'package:tech_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:tech_app/models/notifications-model.dart';
import 'package:tech_app/models/ticket-details-model.dart';
import 'package:tech_app/models/ticket-model.dart';
import 'package:tech_app/screens/ticket-details.dart';
import 'package:tech_app/util/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  Future<void> _handleNotificationTap(
      BuildContext context, NotificationModel notification ) async {
    if (!notification.read) {
      await context.read<NotificationsCubit>().markAsRead(notification.id);
    }

    if (notification.data.type == NotificationType.ticketAssigned ||
        notification.data.type == NotificationType.chat) {
      await navigateToTicketDetails(context, notification);
    }
  }

  Future<void> navigateToTicketDetails(
      BuildContext context, NotificationModel notification) async {
    final ticketId = notification.data.modelId;
    if (ticketId == 0) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ticketDetails =
          await context.read<TicketsCubit>().getTicketDetails(ticketId);
 
          // Then get the full ticket model with all user data
      final fullTicket = await context.read<TicketsCubit>().getTicketById(ticketId);

      if (!mounted) return;
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(
            ticket: ticketDetails,
             userTicket: fullTicket,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ticket: ${e.toString()}')),
      );
    }
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: ColorsHelper.LightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: Card(
        color: notification.read ? Colors.grey[100] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.read 
                ? Colors.grey[300]!
                : Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: notification.read ? 1 : 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(context, notification, ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getNotificationIcon(notification.data.type),
                      color: notification.read
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.read 
                              ? FontWeight.normal 
                              : FontWeight.bold,
                          color: notification.read ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(notification.createdAt),
                      style: TextStyle(
                        color: notification.read 
                            ? Colors.grey[600] 
                            : Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (!notification.read) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: notification.read ? Colors.grey[600] : Colors.grey[800],
                  ),
                ),
                if (notification.data.type != NotificationType.unknown) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      notification.data.type.displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: notification.read ? Colors.grey : Colors.white,
                      ),
                    ),
                    backgroundColor: notification.read 
                        ? Colors.grey[200] 
                        : Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.ticketCreated:
        return Icons.add_alert;
      case NotificationType.ticketUpdated:
        return Icons.edit;
      case NotificationType.ticketAssigned:
        return Icons.assignment_ind;
      case NotificationType.ticketResolved:
        return Icons.check_circle;
      case NotificationType.chat:
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  void _markAllAsRead(BuildContext context) {
    context.read<NotificationsCubit>().markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteAllNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationsCubit>().deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications deleted')),
              );
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<NotificationsCubit, bool>(
      (cubit) => cubit.state is NotificationsLoading,
    );

    final notifications =
        context.read<NotificationsCubit>().technicianNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return Badge(
                  label: Text(state.unreadCount.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.mark_as_unread),
                    onPressed: () => _markAllAsRead(context),
                    tooltip: 'Mark all as read',
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.mark_as_unread),
                onPressed: () => _markAllAsRead(context),
                tooltip: 'Mark all as read',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _deleteAllNotifications(context),
            tooltip: 'Delete all',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (notifications.isEmpty
              ? const Center(child: Text('No notifications available'))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<NotificationsCubit>().loadNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(context, notification);
                    },
                  ),
                )),
    );
  }
}
