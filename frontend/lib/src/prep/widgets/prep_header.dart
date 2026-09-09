import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/widgets/circle_icon_button.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/src/profile/profile_screen.dart';

class PrepHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PrepHeader({super.key, required this.scaffoldKey});

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

    return Container(
      color: AppTheme.appBarBg(context),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu on the LEFT — same side as Scaffold.drawer
            CircleIconButton(
              icon: Icons.menu_rounded,
              onTap: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Testiva',
                  style: TextStyle(
                    color: AppTheme.primaryText(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
