import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

/// Registers the device FCM token with `PUT /user/fcm-token`.
///
/// **One-time setup**
/// - Android: `android/app/google-services.json` + Google Services Gradle plugin
///   (already present for package `com.example.frontend` / project `testivafyp`).
/// - iOS: add `GoogleService-Info.plist`, enable Push Notifications + Background
///   Modes (Remote notifications) in Xcode, then rebuild.
/// - Optional: `flutterfire configure` to generate `lib/firebase_options.dart`
///   if you prefer explicit Dart options instead of native auto-init.
class FcmTokenService {
  FcmTokenService._();

  static bool _firebaseReady = false;
  static bool _refreshListenerAttached = false;

  /// Safe Firebase bootstrap. Returns false if native options are missing
  /// (e.g. no google-services.json / GoogleService-Info.plist) so the app
  /// continues without push registration.
  static Future<bool> ensureFirebaseInitialized() async {
    if (_firebaseReady || Firebase.apps.isNotEmpty) {
      _firebaseReady = true;
      return true;
    }
    try {
      // Prefer Dart options (Android from google-services.json). Falls back to
      // native auto-init when options are unavailable for the platform.
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
      debugPrint('[FcmTokenService] Firebase initialized');
      return true;
    } catch (e, st) {
      debugPrint('[FcmTokenService] Firebase.initializeApp failed: $e');
      debugPrint('$st');
      debugPrint(
        '[FcmTokenService] Push disabled until Firebase native config is '
        'present (Android google-services.json / iOS GoogleService-Info.plist). '
        'Optional: run `flutterfire configure` to regenerate firebase_options.dart.',
      );
      return false;
    }
  }

  /// PUT `/user/fcm-token` when a token is available.
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
  /// Also attaches [onTokenRefresh] once.
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

    // Android 13+ runtime POST_NOTIFICATIONS (also declared in Manifest).
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('[FcmTokenService] Android notification permission: $result');
      }
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
}
