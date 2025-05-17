import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:tech_app/CHAT/pusher-state.dart';

import 'package:tech_app/models/chat_message.dart';

class PusherCubit extends Cubit<PusherState> {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter();
  late String conversationId;
  late String loggedUserId;
  // ignore: unused_field
  bool _isConnected = false;
  bool _isInitialized = false;
  PusherCubit() : super(PusherInitial());

  Future<void> init({
    required String loggedUserId,
    required String conversationId,
    required Function(ChatMessage) onNewMessage,
  }) async {
    if (_isInitialized || state is PusherConnecting) return;
    this.loggedUserId = loggedUserId;
    this.conversationId = conversationId;
    _isInitialized = true;
    try {
      emit(PusherConnecting());
      await _pusher.init(
        apiKey: '4924e59671f5cabb61cb',
        cluster: 'eu',
        onConnectionStateChange: (current, previous) {
          print("Pusher state: $current (prev: $previous)");
          if (current == 'CONNECTED') {
            _isConnected = true;
            emit(PusherConnected());
          } else if (current == 'DISCONNECTED') {
            _isConnected = false;
            emit(PusherDisconnected());
            Future.delayed(
              const Duration(seconds: 2),
              () => _reconnect(onNewMessage),
            );
          }
        },
        onEvent: (event) {
          print("📥 Event from Pusher:");
          print("Channel: ${event.channelName}");
          print("Event: ${event.eventName}");
          print("Data: ${event.data}");
          if (event.eventName == 'new-message' &&
              event.channelName == 'conversations.$conversationId') {
            try {
              final data = jsonDecode(event.data!);
              final message = ChatMessage.fromJson(data);
              onNewMessage(message);
            } catch (e) {
              print("Error parsing new message: $e");
            }
          }
        },
      );
      await _connectToChannels();
    } catch (e) {
      emit(PusherError("Connection failed: $e"));
      _reconnect(onNewMessage);
    }
  }

  Future<void> _connectToChannels() async {
    await _unsubscribeChannels();
    await _pusher.subscribe(channelName: 'chat.$loggedUserId');
    await _pusher.subscribe(channelName: 'conversations.$conversationId');
    await _pusher.connect();
  }

  Future<void> _unsubscribeChannels() async {
    await _pusher.unsubscribe(channelName: 'chat.$loggedUserId');
    await _pusher.unsubscribe(channelName: 'conversations.$conversationId');
  }

  Future<void> _reconnect(Function(ChatMessage) onNewMessage) async {
    if (state is PusherReconnecting || state is PusherConnecting) return;

    emit(PusherReconnecting());
    try {
      await _pusher.disconnect();
      _isConnected = false;
      await _connectToChannels();
    } catch (e) {
      emit(PusherError("Reconnect failed: $e"));
      Future.delayed(
        const Duration(seconds: 5),
        () => _reconnect(onNewMessage),
      );
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _isInitialized = false;
    await _unsubscribeChannels();
    await _pusher.disconnect();
  }

  Future<void> unsubscribeConversation(String conversationId) async {
    await _pusher.unsubscribe(channelName: 'conversations.$conversationId');
  }
}
