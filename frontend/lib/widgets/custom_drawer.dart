import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/widgets/logout_dialog.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _userName = 'User';
  String _userTier = 'Free Member';
  String _initials = 'U';
  bool _isLoadingHeader = true;

  @override
  void initState() {
    super.initState();
    _loadDrawerProfileCache();
  }

  Future<void> _loadDrawerProfileCache() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final String name =
              data['user']['full_name'] ?? data['user']['name'] ?? 'User';
          final bool isPremium = data['user']['isPremium'] == true ||
              (data['user']['subscription'] ?? '')
                      .toString()
                      .toLowerCase() ==
                  'premium';

          String calculatedInitials = 'U';
          List<String> parts = name.trim().split(' ');
          if (parts.length > 1) {
            calculatedInitials =
                '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
            calculatedInitials = parts[0][0].toUpperCase();
          }

          if (mounted) {
            setState(() {
              _userName = name;
              _userTier = isPremium ? 'Premium Member' : 'Free Member';
              _initials = calculatedInitials;
              _isLoadingHeader = false;
            });
            return;
          }
        }
      }
      setState(() => _isLoadingHeader = false);
    } catch (e) {
      debugPrint("Drawer state fallback processing: ${e.toString()}");
      if (mounted) {
        setState(() => _isLoadingHeader = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: AppTheme.drawerBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Dynamic Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF007BFF),
                  child: _isLoadingHeader
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color),
                      ),
                      Text(
                        _userTier,
                        style: TextStyle(
                          fontSize: 13,
                          color: _userTier.contains('Premium')
                              ? const Color(0xFFD97706)
                              : Colors.grey,
                          fontWeight: _userTier.contains('Premium')
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  text: 'Dashboard Home',
                  isSelected:
                      currentRoute == '/home' || currentRoute == '/dashboard',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/home'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.model_training_outlined,
                  text: 'Exam Prep Track',
                  isSelected: currentRoute == '/prep',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/prep'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  text: 'Mock Exams Engine',
                  isSelected: currentRoute == '/mocks',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/mocks'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  text: 'My Profile Metrics',
                  isSelected: currentRoute == '/profile',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/profile'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  text: 'Settings Options',
                  isSelected: currentRoute == '/settings',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/settings'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  text: 'Feedback Support',
                  isSelected: currentRoute == '/feedback',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/feedback'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_none,
                  text: 'Notifications',
                  badgeCount: context.watch<NotificationProvider>().unreadCount,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  final hostContext =
                      Navigator.of(context, rootNavigator: true).overlay!.context;
                  Navigator.pop(context);
                  showDialog(
                    context: hostContext,
                    builder: (dialogContext) => LogoutDialog(hostContext: hostContext),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _navigateToRoute(
      BuildContext context, String? current, String target) {
    Navigator.pop(context);
    if (current != target) {
      Navigator.pushNamedAndRemoveUntil(
          context, target, (route) => route.isFirst);
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF007BFF).withValues(alpha: 0.1)
            : AppTheme.tileItemBg(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF007BFF).withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading:
            Icon(icon, color: isSelected ? const Color(0xFF007BFF) : Colors.blueGrey),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF007BFF)
                : theme.textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}