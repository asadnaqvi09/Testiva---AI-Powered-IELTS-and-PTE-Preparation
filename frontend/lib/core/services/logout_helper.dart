import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/providers/notification_provider.dart';

class LogoutHelper {
  static Future<void> _finishLocalLogout(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    NotificationProvider? notificationProvider;
    try {
      notificationProvider = context.read<NotificationProvider>();
    } catch (_) {}

    notificationProvider?.reset();
    UserNotifier.notifier.value = {};
    socketService.disconnect();
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  static Future<void> performLogout(BuildContext context) async {
    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _finishLocalLogout(context);
    }
  }

  static Future<void> performLogoutAllDevices(BuildContext context) async {
    try {
      await ApiService.logoutAllDevices();
    } catch (e) {
      debugPrint('Logout-all error: $e');
      try {
        await ApiService.clearAuthSession();
      } catch (_) {}
    } finally {
      await _finishLocalLogout(context);
    }
  }
}
