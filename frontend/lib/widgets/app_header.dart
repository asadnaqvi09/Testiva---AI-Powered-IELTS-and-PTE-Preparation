import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../src/profile/profile_screen.dart';
import '../core/services/user_notifier.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool? showBackButton;
  final Widget? titleWidget;
  final bool showProfileAvatar;

  const AppHeader({
    super.key,
    this.scaffoldKey,
    this.showBackButton,
    this.titleWidget,
    this.showProfileAvatar = true,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _AppHeaderState extends State<AppHeader> {
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

  @override
  Widget build(BuildContext context) {
    final userData = UserNotifier.notifier.value;
    final fullName = (userData['name'] ?? 'User').toString();
    final initials = _getInitials(fullName);
    final bool canPop = Navigator.canPop(context);
    final bool displayBackButton = widget.showBackButton ?? canPop;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            displayBackButton
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: AppTheme.cardBg(context),
                         borderRadius: BorderRadius.circular(10),
                         boxShadow: AppTheme.cardShadow(context),
                       ),
                       child: Icon(Icons.arrow_back, size: 20, color: AppTheme.iconColor(context)),
                    ),
                  )
                : GestureDetector(
                    onTap: () => widget.scaffoldKey?.currentState?.openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Icon(Icons.menu, size: 20, color: AppTheme.iconColor(context)),
                    ),
                  ),
            Row(
              children: [
                if (widget.titleWidget != null) ...[
                  widget.titleWidget!,
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Testiva',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(context),
                    ),
                  ),
                ],
              ],
            ),
            widget.showProfileAvatar
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF007BFF),
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
