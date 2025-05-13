import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  PusherChannelsFlutter? pusher;
  
  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  Future<void> initializePusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    try {
      await pusher?.init(
        apiKey: "YOUR_PUSHER_API_KEY",
        cluster: "YOUR_PUSHER_CLUSTER",
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
      );
      await pusher?.connect();
    } catch (e) {
      debugPrint("Error initializing Pusher: $e");
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    debugPrint("Error: $message Code: $code");
  }

  Future<void> subscribeToTicketChannel(String ticketId, Function(dynamic) onMessageReceived) async {
    try {
      String channelName = 'ticket-$ticketId';
      await pusher?.subscribe(
        channelName: channelName,
        onEvent: (event) {
          onMessageReceived(event.data);
        },
      );
    } catch (e) {
      debugPrint("Error subscribing to channel: $e");
    }
  }

  Future<void> unsubscribeFromTicketChannel(String ticketId) async {
    try {
      String channelName = 'ticket-$ticketId';
      await pusher?.unsubscribe(channelName: channelName);
    } catch (e) {
      debugPrint("Error unsubscribing from channel: $e");
    }
  }

  Future<void> sendMessage(String ticketId, Map<String, dynamic> message) async {
    try {
      String channelName = 'ticket-$ticketId';
      await pusher?.trigger(
        PusherEvent(
          channelName: channelName,
          eventName: 'client-message',
          data: message,
        ),
      );
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Future<void> disconnect() async {
    await pusher?.disconnect();
  }
} 