import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/widgets/brand_mark.dart';
import 'package:frontend/widgets/circle_icon_button.dart';
import '../../../profile/profile_screen.dart';
import '../../../../core/services/user_notifier.dart';
import '../../../../providers/notification_provider.dart';
import 'premium_modal.dart';

class HeaderSection extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HeaderSection({super.key, required this.scaffoldKey});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  @override
  void initState() {
    super.initState();
    UserNotifier.notifier.addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    UserNotifier.notifier.removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) setState(() {});
  }

  String _getInitials(String name) {
    try {
      List<String> parts = name.trim().split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    } catch (_) {}
    return 'U';
  }

  void _openMenu() {
    final state = widget.scaffoldKey.currentState;
    if (state == null) return;
    if (state.hasDrawer) {
      state.openDrawer();
    } else if (state.hasEndDrawer) {
      state.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserNotifier.notifier.value;
    final fullName = (userData['name'] ?? 'User').toString();
    final firstName = fullName.split(' ').first;
    final initials = _getInitials(fullName);
    final isPremium = userData['isPremium'] == true ||
        (userData['subscription'] ?? '').toString().toLowerCase() == 'premium';

    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final dateString = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Menu on the LEFT — same side as Scaffold.drawer
            CircleIconButton(icon: Icons.menu_rounded, onTap: _openMenu),
            const Expanded(
              child: Center(child: BrandMark(markSize: 32, fontSize: 17)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.brandBlue,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateString,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.secondaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hello, $firstName! 👋',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText(context),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep up the great work!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.secondaryText(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            CircleIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              badge: unread > 0
                  ? Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        if (!isPremium) ...[
          const SizedBox(height: 18),
          _upgradeBanner(context),
        ],
      ],
    );
  }

  Widget _upgradeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const PremiumModal(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? const Color(0xFF2C2410) : const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.isDark(context) ? const Color(0xFF5C4D26) : const Color(0xFFF5D78E),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: AppTheme.isDark(context) ? const Color(0xFFE8B339) : const Color(0xFFD48806),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Upgrade to Basic — unlock mock tests Rs399/mo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.isDark(context) ? const Color(0xFFFFD591) : const Color(0xFF874D00),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.isDark(context) ? const Color(0xFFE8B339) : const Color(0xFFD48806),
            ),
          ],
        ),
      ),
    );
  }
}
