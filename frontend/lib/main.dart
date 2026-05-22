import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/feedback_provider.dart';

// Screens imports mapping paths tree verification
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/profile/profile_screen.dart';
import 'package:frontend/src/features/settings/presentation/feedback_screen.dart';
import 'package:frontend/src/prep/prep_screen.dart'; // Ensure correct path for Prep Screen
import 'package:frontend/src/mocks/mocks_screen.dart'; // Ensure correct path for Mocks Screen

void main() {
  // Ensuring Flutter binding initialization layer is robustly configured
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      child: const TestivaApp(),
    ),
  );
}

class TestivaApp extends StatelessWidget {
  const TestivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Testiva AI',
          debugShowCheckedModeBanner: false,

          // ☀️ Light Theme Core Configuration Rules
          theme: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            cardColor: AppColors.cardLight,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
            ),
          ),

          // 🌙 Dark Theme Core Configuration Rules
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            cardColor: AppColors.cardDark,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),

          // System Dynamic Theme Modes Switching Handler
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Navigation Pipelines Management Setup Route Trees
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/home': (context) => const DashboardScreen(), // Map clear mapping wrapper matching drawer requests
            '/dashboard': (context) => const DashboardScreen(),
            '/prep': (context) => const PrepScreen(), // Dynamic injection for modules prep track
            '/mocks': (context) => const MocksScreen(), // Full length mock tests launcher screen
            '/profile': (context) => const ProfileScreen(), // Direct profiles map pipeline
            '/settings': (context) => const ProfileScreen(), // Maintained precise legacy navigation map alignment
            '/feedback': (context) => const FeedbackScreen(),
          },
        );
      },
    );
  }
}