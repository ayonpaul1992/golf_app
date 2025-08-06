import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;
  bool _isConnected = false;

  SocketService._internal();

  IO.Socket? get socket => _socket;

  bool get isConnected => _isConnected;

  void init(String token) {
    if (_socket != null && _isConnected) {
      print("✅ Socket already initialized");
      return;
    }

    _socket = IO.io(
      'https://api.dev.driverpos.io',
      <String, dynamic>{
        'transports': ['websocket'],
        'timeout': 5000,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'auth': {'token': token},
      },
    );

    _socket!.onConnect((_) {
      print("✅ Socket connected");
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print("🔌 Socket disconnected");
      _isConnected = false;
    });

    _socket!.onError((err) {
      print("❌ Socket error: $err");
      _isConnected = false;
    });

    _socket!.onConnectError((err) {
      print("❌ Connect error: $err");
    });

    _socket!.connect();
  }

  void dispose() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
  }
}
