import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_page.dart';
import '../../widgets/custom_drawer.dart';
import '../profile/all_tests_screen.dart';
import '../profile/profile_screen.dart';
import '../mocks/mocks_screen.dart';
import '../prep/prep_screen.dart';
import '../features/community/presentation/community_screen.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/core/services/offline_sync_service.dart';
import 'package:frontend/providers/notification_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationProvider? _notificationProvider;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndCheckPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().initialize();
        OfflineSyncService.instance.onSyncComplete = () {
          if (mounted) {
            context.read<NotificationProvider>().refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Offline test uploaded. You will be notified when evaluation completes.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        };
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationProvider?.removeListener(_handlePendingNavigation);
    _notificationProvider = context.read<NotificationProvider>();
    _notificationProvider!.addListener(_handlePendingNavigation);
  }

  @override
  void dispose() {
    _notificationProvider?.removeListener(_handlePendingNavigation);
    super.dispose();
  }

  void _handlePendingNavigation() {
    final tab = _notificationProvider?.pendingDashboardTab;
    final openAllTests = _notificationProvider?.pendingOpenAllTests ?? false;
    final attemptId = _notificationProvider?.pendingAttemptId;

    if (tab != null && mounted) {
      setState(() => _selectedIndex = tab);
    }

    if (openAllTests && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllTestsScreen(initialAttemptId: attemptId),
          ),
        );
      });
    }

    _notificationProvider?.clearPendingNavigation();
  }

  Future<void> _fetchUserProfileAndCheckPreference() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          AuthNavigationHelper.syncUserNotifier(
            Map<String, dynamic>.from(user as Map),
          );

          if (user['preference'] == null && mounted) {
            final userName = user['full_name'] ?? user['name'] ?? 'User';
            Navigator.pushReplacementNamed(
              context,
              '/select-preference',
              arguments: userName,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Dashboard profile fetch error: $e");
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleStartTestFlow() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(
        scaffoldKey: _scaffoldKey,
        onActionTap: _onTabChanged,
        onNavigateToPrep: () => _onTabChanged(2),
      ),
      MocksScreen(onStartTestRequested: _handleStartTestFlow),
      const PrepScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Prep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}