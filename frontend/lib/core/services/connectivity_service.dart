import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

typedef ConnectivityCallback = void Function(bool isOnline);

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  final List<ConnectivityCallback> _listeners = [];

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    _isOnline = await checkOnline();
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) async {
      final online = _resultsIndicateOnline(results);
      if (online != _isOnline) {
        _isOnline = online;
        for (final listener in List<ConnectivityCallback>.from(_listeners)) {
          listener(_isOnline);
        }
      }
    });
  }

  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _resultsIndicateOnline(results);
    return _isOnline;
  }

  bool _resultsIndicateOnline(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
  }

  void addListener(ConnectivityCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(ConnectivityCallback callback) {
    _listeners.remove(callback);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _listeners.clear();
  }
}
