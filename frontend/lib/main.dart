import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/feedback_provider.dart';
import 'package:frontend/src/onboarding/onboarding_screen.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/profile/profile_screen.dart';
import 'package:frontend/src/features/settings/presentation/feedback_screen.dart';
import 'package:frontend/src/prep/prep_screen.dart';
import 'package:frontend/src/mocks/mocks_screen.dart';
import 'package:frontend/src/auth/signup/email_verified_screen.dart';
import 'package:frontend/src/auth/signup/preference_selection_screen.dart';

void main() {
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
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/home': (context) => const DashboardScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/prep': (context) => const PrepScreen(),
            '/mocks': (context) => MocksScreen(onStartTestRequested: () {}),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const ProfileScreen(),
            '/feedback': (context) => const FeedbackScreen(),
            '/email-verified': (context) {
              final userName = ModalRoute.of(context)!.settings.arguments as String? ?? 'User';
              return EmailVerifiedScreen(userName: userName);
            },
            '/select-preference': (context) {
              final userName = ModalRoute.of(context)!.settings.arguments as String? ?? 'User';
              return PreferenceSelectionScreen(userName: userName);
            },
          },
        );
      },
    );
  }
}