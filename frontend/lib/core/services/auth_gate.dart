import 'package:flutter/material.dart';
import 'package:frontend/src/auth/auth_screen.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Launch gate: always show onboarding (first launch) or login.
/// Saved tokens are never used to skip into Home / Dashboard.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static const seenOnboardingPrefsKey = 'has_seen_onboarding';

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(seenOnboardingPrefsKey, true);
  }

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
      final seenOnboarding =
          prefs.getBool(AuthGate.seenOnboardingPrefsKey) ?? false;
      if (seenOnboarding) {
        _go(const AuthScreen(startOnLogin: true, allowBack: false));
      } else {
        _go(const OnboardingScreen());
      }
    } catch (_) {
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
