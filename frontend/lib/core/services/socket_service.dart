import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/services/api_service.dart';

typedef SocketEventHandler = void Function(dynamic data);

class SocketService {
  io.Socket? _socket;
  String? _authedWithToken;
  final Set<VoidCallback> _connectListeners = {};

  bool get isConnected => _socket?.connected ?? false;

  /// Connect to `/community` with the current JWT. Reconnects when the token changes.
  Future<void> connect({bool force = false}) async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) return;

    // clean and optimized code — reuse only if same token still connected
    if (!force &&
        _socket?.connected == true &&
        _authedWithToken == token) {
      return;
    }

    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    _authedWithToken = token;
    _socket = io.io(
      '${ApiService.socketBaseUrl}/community',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(12)
          .setReconnectionDelay(2000)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected to /community');
      for (final listener in List<VoidCallback>.from(_connectListeners)) {
        try {
          listener();
        } catch (e) {
          debugPrint('[Socket] connect listener error: $e');
        }
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
    _authedWithToken = null;
    _socket?.dispose();
    _socket = null;
  }
}

final socketService = SocketService();
