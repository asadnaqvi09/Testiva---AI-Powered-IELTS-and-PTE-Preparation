import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/providers/notification_provider.dart';

class LogoutHelper {
  static Future<void> performLogout(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    NotificationProvider? notificationProvider;
    try {
      notificationProvider = context.read<NotificationProvider>();
    } catch (_) {}

    try {
      notificationProvider?.reset();
      await ApiService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      UserNotifier.notifier.value = {};
      socketService.disconnect();
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
