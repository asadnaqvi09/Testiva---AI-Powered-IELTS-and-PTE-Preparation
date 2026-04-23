import 'package:flutter/material.dart';
import 'src/onboarding/onboarding_screen.dart';
import 'src/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool userIsLoggedIn = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Testiva AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007BFF)),
        useMaterial3: true,
      ),
      home: _getHome(userIsLoggedIn),
    );
  }

  Widget _getHome(bool isLoggedIn) {
    if (isLoggedIn) {
      return const DashboardScreen();
    }
    return const OnboardingScreen();
  }
}