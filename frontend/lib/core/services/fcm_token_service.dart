import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

/// Top-level background handler (must be a top-level or static function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }
  debugPrint(
    '[FcmTokenService] background push: ${message.messageId} '
    'data=${message.data}',
  );
}

/// Registers the device FCM token with `PUT /user/fcm-token`.
///
/// **One-time setup**
/// - Android: `android/app/google-services.json` + Google Services Gradle plugin
/// - iOS: add `GoogleService-Info.plist`, enable Push Notifications
/// - Backend: `GOOGLE_APPLICATION_CREDENTIALS` pointing to a real service-account JSON
class FcmTokenService {
  FcmTokenService._();

  static const androidChannelId = 'testiva_alerts';

  static bool _firebaseReady = false;
  static bool _refreshListenerAttached = false;
  static bool _foregroundListenerAttached = false;
  static bool _openedListenerAttached = false;

  /// Invoked when a push arrives while the app is in the foreground.
  static void Function(Map<String, dynamic> data)? onForegroundMessage;

  /// Invoked when user taps a notification (background / terminated).
  static void Function(Map<String, dynamic> data)? onNotificationOpened;

  /// Safe Firebase bootstrap. Returns false if native options are missing.
  static Future<bool> ensureFirebaseInitialized() async {
    if (_firebaseReady || Firebase.apps.isNotEmpty) {
      _firebaseReady = true;
      _attachForegroundListener();
      _attachOpenedListeners();
      return true;
    }
    try {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on UnsupportedError catch (e) {
        debugPrint(
          '[FcmTokenService] No Dart FirebaseOptions for platform: $e',
        );
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
      await _ensureAndroidChannel();
      _attachForegroundListener();
      _attachOpenedListeners();
      debugPrint('[FcmTokenService] Firebase initialized');
      return true;
    } catch (e, st) {
      debugPrint('[FcmTokenService] Firebase.initializeApp failed: $e');
      debugPrint('$st');
      debugPrint(
        '[FcmTokenService] Push disabled until Firebase native config is '
        'present (Android google-services.json / iOS GoogleService-Info.plist).',
      );
      return false;
    }
  }

  static Future<bool> registerToken(String? token) async {
    if (token == null || token.trim().isEmpty) return false;
    try {
      final response = await ApiService.updateFcmToken(token.trim());
      final ok = response.statusCode == 200;
      if (!ok) {
        debugPrint(
          '[FcmTokenService] register HTTP ${response.statusCode}: '
          '${response.body}',
        );
      }
      return ok;
    } catch (e) {
      debugPrint('[FcmTokenService] register failed: $e');
      return false;
    }
  }

  /// Request permission, read FCM token, sync to backend when logged in.
  static Future<void> syncTokenIfAvailable() async {
    try {
      final authToken = await ApiService.getToken();
      if (authToken == null || authToken.trim().isEmpty) {
        debugPrint('[FcmTokenService] skip sync: user not logged in');
        return;
      }

      if (!_isMobilePlatform) {
        debugPrint(
          '[FcmTokenService] skip sync: FCM only on Android/iOS '
          '(current: $defaultTargetPlatform)',
        );
        return;
      }

      final ready = await ensureFirebaseInitialized();
      if (!ready) return;

      await _requestPermissionIfNeeded();
      _attachTokenRefreshListener();
      _attachForegroundListener();
      _attachOpenedListeners();

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('[FcmTokenService] no FCM token available yet');
        return;
      }

      final ok = await registerToken(fcmToken);
      debugPrint(
        ok
            ? '[FcmTokenService] FCM token synced to backend'
            : '[FcmTokenService] FCM token sync failed',
      );
    } catch (e, st) {
      debugPrint('[FcmTokenService] syncTokenIfAvailable error: $e');
      debugPrint('$st');
    }
  }

  /// Consume a cold-start notification tap (call after NotificationProvider is ready).
  static Future<void> consumeInitialMessage() async {
    try {
      if (!_firebaseReady) return;
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial == null) return;
      final data = _messageToMap(initial);
      debugPrint('[FcmTokenService] initial message: $data');
      onNotificationOpened?.call(data);
    } catch (e) {
      debugPrint('[FcmTokenService] consumeInitialMessage: $e');
    }
  }

  static bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<void> _requestPermissionIfNeeded() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      '[FcmTokenService] notification permission: '
      '${settings.authorizationStatus}',
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('[FcmTokenService] Android notification permission: $result');
      }
    }
  }

  static Future<void> _ensureAndroidChannel() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      // Backend FCM payload uses android.notification.channelId = testiva_alerts.
      // Android auto-creates the channel on first receive; presentation options
      // keep alerts visible when the app is foregrounded on iOS.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[FcmTokenService] android channel setup: $e');
    }
  }

  static void _attachTokenRefreshListener() {
    if (_refreshListenerAttached) return;
    _refreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) async {
        final authToken = await ApiService.getToken();
        if (authToken == null || authToken.trim().isEmpty) {
          debugPrint(
            '[FcmTokenService] onTokenRefresh: skip (not logged in)',
          );
          return;
        }
        final ok = await registerToken(token);
        debugPrint(
          ok
              ? '[FcmTokenService] refreshed FCM token synced'
              : '[FcmTokenService] refreshed FCM token sync failed',
        );
      },
      onError: (Object e) {
        debugPrint('[FcmTokenService] onTokenRefresh error: $e');
      },
    );
  }

  // clean and optimized code — refresh inbox while app is foreground
  static void _attachForegroundListener() {
    if (_foregroundListenerAttached || !_firebaseReady) return;
    _foregroundListenerAttached = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = _messageToMap(message);
      debugPrint('[FcmTokenService] foreground push: $data');
      onForegroundMessage?.call(data);
    });
  }

  static void _attachOpenedListeners() {
    if (_openedListenerAttached || !_firebaseReady) return;
    _openedListenerAttached = true;
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = _messageToMap(message);
      debugPrint('[FcmTokenService] opened from background: $data');
      onNotificationOpened?.call(data);
    });
  }

  static Map<String, dynamic> _messageToMap(RemoteMessage message) {
    return <String, dynamic>{
      ...message.data,
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null)
        'body': message.notification!.body,
    };
  }
}
