import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // Core ApiService mapping helper
import 'widgets/profile_header.dart';
import '../dashboard/home/widgets/stats_row.dart';
import 'widgets/progress_graph.dart';
import 'widgets/preference_tiles.dart';
import 'widgets/support_section.dart';

import '../../widgets/custom_drawer.dart';
import '../../widgets/logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  // Real-time user profile data states storage matrices
  Map<String, dynamic> _userData = {
    'name': 'Ali Khan',
    'email': 'ali.khan@example.com',
    'isPremium': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserProfileData();
  }

  // 🚀 Fetch Profile data metrics from database endpoint
  Future<void> _fetchUserProfileData() async {
    try {
      final response = await ApiService.get('/auth/profile');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          setState(() {
            _userData = {
              'name': data['user']['name'] ?? 'User Name',
              'email': data['user']['email'] ?? 'user@email.com',
              'isPremium': data['user']['isPremium'] ?? data['user']['is_premium'] ?? false,
            };
            _isLoading = false;
          });
          return;
        }
      }
      // If endpoint response gives errors, silently adapt with standard parameters fallback
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Profile state fetching exception caught: ${e.toString()}");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
            : RefreshIndicator(
          onRefresh: _fetchUserProfileData,
          color: const Color(0xFF007BFF),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Forwarding live user variables to child layout parameters wrapper
                ProfileHeader(
                    isDarkMode: isDarkMode,
                    userData: _userData
                ),
                const SizedBox(height: 25),
                const StatsRow(),
                const SizedBox(height: 25),
                const ProgressGraph(),
                const SizedBox(height: 30),
                const Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                PreferenceTiles(isDarkMode: isDarkMode),
                const SizedBox(height: 25),
                const Text('Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const SupportSection(),
                const SizedBox(height: 30),
                _buildLogoutButton(context),
                const SizedBox(height: 25),
                const Center(
                    child: Text(
                        'Testiva v1.0.0 • © 2026',
                        style: TextStyle(color: Colors.grey, fontSize: 11)
                    )
                ),
                const SizedBox(height: 20),
              ],
            ),
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
          showDialog(
            context: context,
            builder: (context) => const LogoutDialog(),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}