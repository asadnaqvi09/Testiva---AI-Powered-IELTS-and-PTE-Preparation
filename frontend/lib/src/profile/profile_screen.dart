import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import '../dashboard/home/widgets/stats_row.dart';
import 'widgets/progress_graph.dart';
import 'widgets/preference_tiles.dart';
import 'widgets/support_section.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(isDarkMode: isDarkMode),
              const SizedBox(height: 25),
              const StatsRow(),
              const SizedBox(height: 25),
              const ProgressGraph(),
              const SizedBox(height: 30),
              const Text("Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              PreferenceTiles(isDarkMode: isDarkMode),
              const SizedBox(height: 25),
              const Text("Support", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const SupportSection(),
              const SizedBox(height: 30),
              _buildLogoutButton(context),
              const SizedBox(height: 25),
              const Center(child: Text("Testiva v1.0.0 • © 2026", style: TextStyle(color: Colors.grey, fontSize: 11))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFFFF1F2),
      ),
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false,
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Text("Logout", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}