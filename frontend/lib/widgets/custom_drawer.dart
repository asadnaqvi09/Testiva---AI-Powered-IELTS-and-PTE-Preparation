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
  bool _isPremium = false;
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
              _isPremium = isPremium;
              _userTier = isPremium ? 'Premium Member' : 'Free Member';
              _initials = calculatedInitials;
              _isLoadingHeader = false;
            });
            return;
          }
        }
      }
      if (mounted) setState(() => _isLoadingHeader = false);
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
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 16, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.brandBlue,
                  child: _isLoadingHeader
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (_isPremium) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFE8B339),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              _userTier,
                              style: TextStyle(
                                fontSize: 13,
                                color: _isPremium
                                    ? const Color(0xFFD97706)
                                    : Colors.grey,
                                fontWeight: _isPremium
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 22, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  text: 'Settings',
                  isSelected: currentRoute == '/settings',
                  onTap: () =>
                      _navigateToRoute(context, currentRoute, '/settings'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  text: 'Feedback',
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
                _buildDrawerItem(
                  context,
                  icon: Icons.star_outline,
                  text: 'Rate App',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Thanks for supporting Testiva!')),
                    );
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  final hostContext = Navigator.of(context, rootNavigator: true)
                      .overlay!
                      .context;
                  Navigator.pop(context);
                  showDialog(
                    context: hostContext,
                    builder: (dialogContext) =>
                        LogoutDialog(hostContext: hostContext),
                  );
                },
                icon: const Icon(Icons.logout, color: Color(0xFFDC2626), size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(
      BuildContext context, String? current, String target) {
    final navigator = Navigator.of(context);
    navigator.pop(); // close drawer only
    if (current == target) return;
    // Push on top of Dashboard — do NOT removeUntil first/AuthGate
    // (that left onboarding under the stack and looked like a logout).
    navigator.pushNamed(target);
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
    final borderColor = AppTheme.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE8ECF0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.brandBlue.withValues(alpha: 0.1)
            : AppTheme.tileItemBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppTheme.brandBlue.withValues(alpha: 0.3)
              : borderColor,
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(icon, color: AppTheme.brandBlue),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? AppTheme.brandBlue
                : theme.textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
