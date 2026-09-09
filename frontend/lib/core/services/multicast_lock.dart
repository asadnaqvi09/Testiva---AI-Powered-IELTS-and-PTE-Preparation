import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android [WifiManager.MulticastLock] via platform channel.
/// Required for mDNS on many physical devices; no-op elsewhere.
class MulticastLock {
  MulticastLock._();

  static const _channel = MethodChannel('testiva/multicast_lock');

  static Future<void> acquire() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('acquire');
    } catch (e) {
      debugPrint('[Testiva] multicast lock acquire failed: $e');
    }
  }

  static Future<void> release() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('release');
    } catch (e) {
      debugPrint('[Testiva] multicast lock release failed: $e');
    }
  }
}
