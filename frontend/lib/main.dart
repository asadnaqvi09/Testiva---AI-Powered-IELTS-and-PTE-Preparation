import  'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/feedback_provider.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/profile/profile_screen.dart';
import 'package:frontend/src/features/settings/presentation/feedback_screen.dart';

void main() {
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
          theme: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            cardColor: AppColors.cardLight,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            cardColor: AppColors.cardDark,
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/settings': (context) => const ProfileScreen(),
            '/feedback': (context) => const FeedbackScreen(),
          },
        );
      },
    );
  }
}