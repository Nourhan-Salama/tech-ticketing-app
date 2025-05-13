import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _isInitialized = false;
  static Function(PusherEvent)? onEvent;
  static String? _userId;

  static Future<void> initPusher({required String userId}) async {
    if (_isInitialized) return;
    _userId = userId;
    
    try {
      await _pusher.init(
        apiKey: '4924e59671f5cabb61cb',
        cluster: 'eu',
        onEvent: (event) => onEvent?.call(event),
        onError: (message, code, error) => print("Pusher error: $message"),
      );
      
      await _pusher.connect();
      _isInitialized = true;
    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  static Future<void> subscribeToConversation(String conversationId) async {
    if (!_isInitialized) return;
    await _pusher.subscribe(channelName: 'conversations.$conversationId');
  }

  static Future<void> unsubscribeFromConversation(String conversationId) async {
    if (!_isInitialized) return;
    await _pusher.unsubscribe(channelName: 'conversations.$conversationId');
  }

  static Future<void> disconnect() async {
    if (!_isInitialized) return;
    await _pusher.disconnect();
    _isInitialized = false;
    _userId = null;
  }

  static String? get userId => _userId;
}