import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/onboarding/onboarding_screen.dart';
import 'src/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TestivaApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

class TestivaApp extends StatelessWidget {
  const TestivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool userIsLoggedIn = false;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Testiva AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF007BFF),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF121212),
              primary: Color(0xFF007BFF),
            ),
            cardColor: const Color(0xFF1E1E1E),
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: _getHome(userIsLoggedIn),
        );
      },
    );
  }

  Widget _getHome(bool isLoggedIn) {
    if (isLoggedIn) {
      return const DashboardScreen();
    }
    return const OnboardingScreen();
  }
}