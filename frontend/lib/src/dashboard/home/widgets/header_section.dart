import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../profile/profile_screen.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/user_notifier.dart';

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

  @override
  Widget build(BuildContext context) {
    final userData = UserNotifier.notifier.value;
    final fullName = (userData['name'] ?? 'User').toString();
    final firstName = fullName.split(' ').first;
    final initials = _getInitials(fullName);

    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final dateString = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.menu, size: 20),
              ),
            ),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text('Testiva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            GestureDetector(
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
            ),
          ],
        ),
        const SizedBox(height: 25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateString, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Hello, $firstName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
            const Text('Keep up the great work!', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 20),
        _premiumBanner(),
      ],
    );
  }

  Widget _premiumBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF9E7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFE58F)),
    ),
    child: const Row(
      children: [
        Icon(Icons.workspace_premium_outlined, color: Color(0xFFD48806), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Unlock IELTS & PTE - Get Premium',
            style: TextStyle(color: Color(0xFF874D00), fontWeight: FontWeight.w600),
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFFD48806)),
      ],
    ),
  );
}