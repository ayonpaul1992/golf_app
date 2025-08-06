import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  bool isConnected = false;
  Completer<void> _readyCompleter = Completer<void>();

  Future<void> init(String token) async {
    if (socket != null && isConnected) return;

    socket = IO.io(
      'https://api.dev.driverpos.io',
      <String, dynamic>{
        'transports': ['websocket'],
        'auth': {'token': token},
        'reconnection': true,
        'reconnectionAttempts': 5,
      },
    );

    socket!.onConnect((_) {
      isConnected = true;
      print("✅ Socket connected");
      if (!_readyCompleter.isCompleted) _readyCompleter.complete();
    });

    socket!.onDisconnect((_) {
      isConnected = false;
      _readyCompleter = Completer(); // Reset completer
    });

    socket!.onConnectError((e) => print("❌ Connect Error: $e"));

    socket!.connect();
  }

  Future<void> waitUntilConnected() => _readyCompleter.future;

  /// Clean up listeners and close socket connection
  void dispose() {
    if (socket != null) {
      socket!.clearListeners();
      socket!.disconnect();
      socket!.destroy();
      socket = null;
      isConnected = false;
      _readyCompleter = Completer(); // Reset
      print("🧹 Socket disposed");
    }
  }
}
