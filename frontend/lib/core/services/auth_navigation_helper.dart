import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/fcm_token_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/src/auth/signup/preference_selection_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';

class AuthNavigationHelper {
  static void syncUserNotifier(Map<String, dynamic> user) {
    final unlocked = user['unlocked_exam']?.toString();
    final subscription = user['subscription'] ?? 'free';
    UserNotifier.notifier.value = {
      ...UserNotifier.notifier.value,
      'id': user['id'] ?? UserNotifier.notifier.value['id'],
      'name': user['full_name'] ?? user['name'] ?? 'User',
      'email': user['email'] ?? '',
      'preference': user['preference'],
      'unlocked_exam': unlocked,
      'role': user['role'] ?? 'user',
      'subscription': subscription,
      'isPremium':
          subscription.toString().toLowerCase() == 'premium' ||
          unlocked?.toUpperCase() == 'BOTH',
      'avatar_url': user['avatar_url'],
    };
  }

  /// Refresh subscription / unlocked_exam from `GET /payments/me`.
  static Future<void> refreshEntitlements() async {
    try {
      final response = await ApiService.get('/payments/me');
      if (response.statusCode != 200) return;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) return;
      final data = body['data'];
      if (data is! Map) return;
      final unlocked = data['unlocked_exam']?.toString();
      final subscription = data['subscription'] ?? 'free';
      UserNotifier.notifier.value = {
        ...UserNotifier.notifier.value,
        'subscription': subscription,
        'preference':
            data['preference'] ?? UserNotifier.notifier.value['preference'],
        'unlocked_exam': unlocked,
        'isPremium':
            subscription.toString().toLowerCase() == 'premium' ||
            unlocked?.toUpperCase() == 'BOTH',
      };
    } catch (e) {
      debugPrint('refreshEntitlements: $e');
    }
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
    unawaited(refreshEntitlements());
    unawaited(FcmTokenService.syncTokenIfAvailable());
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

    // Mobile is always the student app. Admin role never opens Admin-Prototype
    // or any admin web dashboard from Flutter.
    final preference = user['preference'];
    final hasPreference =
        preference != null && preference.toString().trim().isNotEmpty;
    final userName = user['full_name'] ?? user['name'] ?? 'User';

    final Widget destination = hasPreference
        ? const DashboardScreen()
        : PreferenceSelectionScreen(userName: userName);

    // Clear AuthGate/Onboarding (and AuthScreen) so Android back cannot return
    // to the welcome flow after the user has entered the app.
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(destination),
      (route) => false,
    );
  }
}
