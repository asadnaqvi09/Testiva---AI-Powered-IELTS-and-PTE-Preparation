import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/services/api_service.dart';

typedef SocketEventHandler = void Function(dynamic data);

class SocketService {
  io.Socket? _socket;
  final Set<VoidCallback> _connectListeners = {};

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) return;

    disconnect();

    _socket = io.io(
      '${ApiService.socketBaseUrl}/community',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected to /community');
      for (final listener in _connectListeners) {
        listener();
      }
    });

    _socket!.onConnectError((data) {
      debugPrint('[Socket] Connect error: $data');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
    });
  }

  void onConnect(VoidCallback callback) {
    _connectListeners.add(callback);
    if (isConnected) callback();
  }

  void removeConnectListener(VoidCallback callback) {
    _connectListeners.remove(callback);
  }

  void on(String event, SocketEventHandler handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [SocketEventHandler? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  void disconnect() {
    _connectListeners.clear();
    _socket?.dispose();
    _socket = null;
  }
}

final socketService = SocketService();
