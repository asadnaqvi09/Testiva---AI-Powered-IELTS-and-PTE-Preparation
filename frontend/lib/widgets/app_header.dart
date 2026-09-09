import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'brand_mark.dart';
import 'circle_icon_button.dart';
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
  Size get preferredSize => const Size.fromHeight(64);
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

  void _openMenu() {
    final state = widget.scaffoldKey?.currentState;
    if (state == null) return;
    if (state.hasEndDrawer) {
      state.openEndDrawer();
    } else {
      state.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserNotifier.notifier.value;
    final fullName = (userData['name'] ?? 'User').toString();
    final initials = _getInitials(fullName);
    final bool canPop = Navigator.canPop(context);
    final bool displayBackButton = widget.showBackButton ?? canPop;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            CircleIconButton(
              icon: displayBackButton ? Icons.arrow_back_rounded : Icons.menu_rounded,
              onTap: displayBackButton ? () => Navigator.pop(context) : _openMenu,
            ),
            const Expanded(
              child: Center(
                child: BrandMark(markSize: 32, fontSize: 17),
              ),
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
                  )
                : const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
