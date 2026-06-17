import 'package:flutter/material.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/src/auth/signup/preference_selection_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';

class AuthNavigationHelper {
  static void syncUserNotifier(Map<String, dynamic> user) {
    UserNotifier.notifier.value = {
      'id': user['id'],
      'name': user['full_name'] ?? user['name'] ?? 'User',
      'email': user['email'] ?? '',
      'preference': user['preference'],
      'role': user['role'] ?? 'user',
      'subscription': user['subscription'] ?? 'free',
      'isPremium':
          (user['subscription'] ?? '').toString().toLowerCase() == 'premium',
      'avatar_url': user['avatar_url'],
    };
  }

  static Route<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Future<void> navigateAfterAuth(
    BuildContext context, {
    required Map<String, dynamic> user,
    String? successMessage,
  }) async {
    syncUserNotifier(user);
    if (!context.mounted) return;

    if (successMessage != null && successMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!context.mounted) return;
    }

    final preference = user['preference'];
    final hasPreference =
        preference != null && preference.toString().trim().isNotEmpty;
    final userName = user['full_name'] ?? user['name'] ?? 'User';

    final Widget destination = hasPreference
        ? const DashboardScreen()
        : PreferenceSelectionScreen(userName: userName);

    Navigator.of(context).pushReplacement(fadeRoute(destination));
  }
}
