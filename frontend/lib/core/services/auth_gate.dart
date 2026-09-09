import 'package:flutter/material.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Launch gate: always show the Figma-style welcome/onboarding on cold start.
/// Get Started / Guest navigate to AuthScreen; successful sign-in enters the app.
/// Tokens alone never skip into Home / Dashboard.
///
/// We intentionally do **not** persist a "has seen onboarding" flag — that made
/// the welcome screen disappear forever after one tap during FYP demos.
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
      // Clear legacy permanent-skip flags so stale prefs cannot hide welcome.
      for (final key in AuthGate._legacySeenKeys) {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
        }
      }
    } catch (_) {
      // Ignore prefs errors — still show onboarding.
    }
    _go(const OnboardingScreen());
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
