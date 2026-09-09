import 'dart:async';
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
          unawaited(AuthNavigationHelper.refreshEntitlements());

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
      const ProfileScreen(asTab: true),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _TestivaBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

class _TestivaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TestivaBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.description_outlined, Icons.description, 'Mocks'),
      (Icons.menu_book_outlined, Icons.menu_book, 'Prep'),
      (Icons.people_outline, Icons.people, 'Community'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(
            children: List.generate(items.length, (index) {
              final active = currentIndex == index;
              final item = items[index];
              final color = active ? const Color(0xFF007BFF) : const Color(0xFF94A3B8);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(active ? item.$2 : item.$1, color: color, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF007BFF) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}