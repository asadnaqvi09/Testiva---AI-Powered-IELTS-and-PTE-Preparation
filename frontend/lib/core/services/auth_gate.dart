import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/src/auth/signup/preference_selection_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cold start gate:
/// 1) Valid JWT → refresh → Dashboard / Preference screen
/// 2) No / invalid token → Onboarding → Auth
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static const _legacySeenKeys = [
    'has_seen_onboarding',
    'has_seen_onboarding_v2',
  ];

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // This is a comment: clear legacy permanent-skip flags
      for (final key in AuthGate._legacySeenKeys) {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
        }
      }

      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        _go(const OnboardingScreen());
        return;
      }

      // This is a comment: try refresh then load profile for session restore
      await ApiService.tryRefreshPublic();
      final profileRes = await ApiService.get('/user/profile');
      if (profileRes.statusCode != 200) {
        await ApiService.clearAuthSession();
        _go(const OnboardingScreen());
        return;
      }

      final body = jsonDecode(profileRes.body);
      if (body is! Map || body['success'] != true) {
        await ApiService.clearAuthSession();
        _go(const OnboardingScreen());
        return;
      }

      final userRaw = body['user'] ?? body['data'];
      final user = userRaw is Map
          ? Map<String, dynamic>.from(userRaw)
          : <String, dynamic>{};
      if (user.isEmpty) {
        await ApiService.clearAuthSession();
        _go(const OnboardingScreen());
        return;
      }

      AuthNavigationHelper.syncUserNotifier(user);
      // Entitlements refresh is fire-and-forget
      // ignore: unawaited_futures
      AuthNavigationHelper.refreshEntitlements();

      final preference = user['preference'];
      final hasPreference =
          preference != null && preference.toString().trim().isNotEmpty;
      final userName = user['full_name'] ?? user['name'] ?? 'User';

      _go(
        hasPreference
            ? const DashboardScreen()
            : PreferenceSelectionScreen(userName: userName.toString()),
      );
    } catch (_) {
      try {
        await ApiService.clearAuthSession();
      } catch (_) {}
      _go(const OnboardingScreen());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;
    setState(() {
      _destination = page;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _destination == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _destination!;
  }
}
