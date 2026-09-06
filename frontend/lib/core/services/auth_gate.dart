import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/auth/signup/preference_selection_screen.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';

/// Cold-start gate: restore session from tokens or show onboarding.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

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
      final access = await ApiService.getToken();
      final refresh = await ApiService.getRefreshToken();

      if (access == null || access.isEmpty) {
        _go(const OnboardingScreen());
        return;
      }

      var profileOk = await _tryLoadProfile();
      if (!profileOk && refresh != null && refresh.isNotEmpty) {
        final refreshed = await ApiService.tryRefreshPublic();
        if (refreshed) {
          profileOk = await _tryLoadProfile();
        }
      }

      if (!profileOk) {
        await ApiService.clearAuthSession();
        _go(const OnboardingScreen());
        return;
      }

      final user = UserNotifier.notifier.value;
      final preference = user['preference'];
      final hasPreference =
          preference != null && preference.toString().trim().isNotEmpty;
      final name = user['name']?.toString() ?? 'User';

      if (hasPreference) {
        _go(const DashboardScreen());
      } else {
        _go(PreferenceSelectionScreen(userName: name));
      }
    } catch (_) {
      _go(const OnboardingScreen());
    }
  }

  Future<bool> _tryLoadProfile() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) return false;
      final user = Map<String, dynamic>.from(
        (body['user'] as Map?) ?? (body['data'] as Map?) ?? {},
      );
      if (user.isEmpty) return false;
      AuthNavigationHelper.syncUserNotifier(user);
      return true;
    } catch (_) {
      return false;
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
